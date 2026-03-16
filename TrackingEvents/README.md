# Tracking Events

This is a full example on how we sync iOS and Android analytics for [SATS](https://sats.no).

This example has 2 folders, which in our real setup are two different repos.

- **EventDefinitions**: Where you find `events.yaml` which define the possible tracking events to see.
- **TrackingEventsPackage**: This is a SPM package for iOS with 2 main products:
    - **TrackingEvents**: a library that contains the generated tracking events as swift types.
    - **TrackingGenerator**: a command line utility that reads the `events.yaml` and create the swift code.

This example is fully functional.

To generate the events you can just run:

```bash
make
```

