# Tracking Events

This sample shows one way to keep iOS and Android analytics event definitions
in sync. It uses shared YAML definitions and a Swift package generator to
produce strongly typed iOS tracking APIs.

## Related Content

### 1. [Syncing iOS and Android tracking events](https://craftingswift.dev/articles/syncing-ios-and-android-tracking-events)

This is a full example on how we sync iOS and Android analytics for [SATS](https://sats.no).

## Structure

This example has 2 folders, which in our real setup are two different repos.

- **EventDefinitions**: Where you find `events.yaml` which define the possible tracking events to see.
- **TrackingEventsPackage**: This is a SPM package for iOS with 2 main products:
    - **TrackingEvents**: a library that contains the generated tracking events as swift types.
    - **TrackingGenerator**: a command line utility that reads the `events.yaml` and create the swift code.

## Setup

This example is fully functional.

To generate the events you can just run:

```bash
make
```
