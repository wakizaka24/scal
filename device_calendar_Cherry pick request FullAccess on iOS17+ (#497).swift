public class SwiftDeviceCalendarPlugin {
    private func requestPermissions(completion: @escaping (Bool) -> Void) {
        if hasEventPermissions() {
            completion(true)
            return
        }
        if #available(iOS 17, *) {
            eventStore.requestFullAccessToEvents {
                (accessGranted: Bool, _: Error?) in
                completion(accessGranted)
            }
        } else {
            eventStore.requestAccess(to: .event, completion: {
                (accessGranted: Bool, _: Error?) in
                completion(accessGranted)
            })
        }
    }

    private func hasEventPermissions() -> Bool {
        let status = EKEventStore.authorizationStatus(for: .event)
        if #available(iOS 17, *) {
            return status == EKAuthorizationStatus.fullAccess
        } else {
            return status == EKAuthorizationStatus.authorized
        }
    }
}