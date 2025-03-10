export interface EventHubMessageConfig {
  test: boolean
}

export type EventHubMessageKeys = keyof EventHubMessageConfig

export type EventHubMessageParams<T extends EventHubMessageKeys> = T extends keyof EventHubMessageConfig
  ? EventHubMessageConfig[T]
  : never;
