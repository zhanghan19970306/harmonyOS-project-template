import { EventHubMessageKeys, EventHubMessageParams } from "./model"

export class EventHubUtils {

  static $emit<T extends EventHubMessageKeys>(event: T, params: EventHubMessageParams<T>) {
    getContext().eventHub.emit(event, params)
  }

  static $on<T extends EventHubMessageKeys>(event: T, callback: (params: EventHubMessageParams<T>) => void) {
    getContext().eventHub.on(event, (params: EventHubMessageParams<T>) => {
      callback(params)
    })
  }

  static $off<T extends EventHubMessageKeys>(event: T, callback?: Function) {
    getContext().eventHub.off(event, callback)
  }
}
