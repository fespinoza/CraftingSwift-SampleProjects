import ActivityKit
import LiveActivityContent
import SwiftUI

struct ContentView: View {
    @State private var activity: Activity<ScoreActivityAttributes>?
    @State private var allActivities: [Activity<ScoreActivityAttributes>] = []

    @State private var demoContent = DemoContent()

    var body: some View {
        VStack(alignment: .leading, spacing: 24) {
            VStack(alignment: .leading, spacing: 16) {
                Text("Activity Operations").font(.headline)

                if let activity {
                    Text("Current Activity: \(activity.id)")
                }

                HStack {
                    Button("Start", action: startActivity)

                    Menu("Update", content: {
                        Button("match start", action: { updateActivity(newState: demoContent.matchStart()) })
                        Button("first goal", action: { updateActivity(newState: demoContent.firstGoal()) })
                        Button("half time", action: { updateActivity(newState: demoContent.halfTime()) })
                        Button("second goal", action: { updateActivity(newState: demoContent.secondGoal()) })
                        Button("third goal", action: { updateActivity(newState: demoContent.thirdGoal()) })
                    })
                    .disabled(activity == nil)

                    Button("End", action: finishActivity)
                        .disabled(activity == nil)
                }
                .buttonStyle(.borderedProminent)
            }

            VStack(alignment: .leading, spacing: 16) {
                HStack {
                    Text("Activity List").font(.headline)

                    Spacer()

                    Button("Refresh", action: refreshActivities)
                }

                if allActivities.isEmpty {
                    Text("No activities running at the moment")
                } else {
                    ForEach(allActivities) { activity in
                        Text(activity.id)
                    }
                }
            }

            Spacer()
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .onAppear(perform: refreshActivities)
        .padding()
        .navigationTitle("Live Activity Demo")
        .task { await requestPushPermissions() }
        .task { await listenForTokenToStartActivityViaPush() }
        .task { await listenForTokenToUpdateActivityViaPush() }
    }

    func refreshActivities() {
        allActivities = Activity<ScoreActivityAttributes>.activities
        activity = allActivities.first
    }

    func requestPushPermissions() async {
        do {
            let _ = try await UNUserNotificationCenter
                .current()
                .requestAuthorization(options: [.alert, .badge, .sound])
            print("got authorization")
        } catch {
            print("error requesting authorization: \(error)")
        }
    }

    func listenForTokenToStartActivityViaPush() async {
        for await pushToken in Activity<ScoreActivityAttributes>.pushToStartTokenUpdates {
            let pushTokenString = pushToken.reduce("") { $0 + String(format: "%02x", $1) }
            print("=== [START] ScoreActivityAttributes: \(pushTokenString)")
        }
    }

    func listenForTokenToUpdateActivityViaPush() async {
        for await activityData in Activity<ScoreActivityAttributes>.activityUpdates {
            for await tokenData in activityData.pushTokenUpdates {
                let token = tokenData.map { String(format: "%02x", $0) }.joined()
                print("=== [UPDATE] ScoreActivityAttributes [\(activityData.id)] : \(token)")
            }

            for await stateUpdate in activityData.activityStateUpdates {
                print("=== [STATE] ScoreActivityAttributes [\(activityData.id)] : \(stateUpdate)")
            }

            for await newContent in activityData.contentUpdates {
                print("=== [CONTENT] ScoreActivityAttributes [\(activityData.id)] : \(newContent)")
            }
        }
    }

    func startActivity() {
        let attrs = ScoreActivityAttributes.previewValue()

        let initialState = ScoreActivityAttributes.ContentState.previewValue(
            matchState: .notYetStarted,
            blueTeamScore: 0,
            redTeamScore: 0
        )
        let content = ActivityContent(state: initialState, staleDate: nil)

        do {
            activity = try Activity.request(
                attributes: attrs,
                content: content,
                pushType: .token
            )

        } catch {
            print(error.localizedDescription)
        }
    }

    func updateActivity(newState: ScoreActivityAttributes.ContentState) {
        guard let activity else { return }

        Task { @MainActor in
            let content = ActivityContent(state: newState, staleDate: nil)
            await activity.update(
                content,
                alertConfiguration: .init(
                    title: "New content!",
                    body: "The match is getting interesting",
                    sound: .default
                )
            )
        }
    }

    func finishActivity() {
        guard let activity else { return }

        Task {
            let finalContent = demoContent.matchEnded()
            let dismissalPolicy: ActivityUIDismissalPolicy = .default

            await activity.end(
                ActivityContent(state: finalContent, staleDate: nil),
                dismissalPolicy: dismissalPolicy
            )

            self.activity = nil
        }
    }
}

#Preview {
    NavigationStack {
        ContentView()
    }
}
