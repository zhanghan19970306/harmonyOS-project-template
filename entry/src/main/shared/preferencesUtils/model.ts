import { preferences } from "@kit.ArkData";

interface PreferenceConfig {
  qmai: {
    /** 是否为第一次启动 */
    isFirstLaunch: boolean,
  }
}

export type PreferenceScope = keyof PreferenceConfig

export type GetPreferenceKey<T extends PreferenceScope> = (keyof PreferenceConfig[T]) & string

export type GetPreferenceValue<T extends PreferenceScope, K extends GetPreferenceKey<T>> = PreferenceConfig[T][K]
  & preferences.ValueType;

export type GetPreferenceValueDefault<T extends preferences.ValueType> = T extends boolean ? boolean :
  T extends string[] ? T :
    T extends number[] ? T :
      T extends boolean[] ? T :
        T extends string ? string :
          T extends number ? number | '' :
            T extends object ? null :
              preferences.ValueType;

export interface DebugOptions {
  /** debug状态时 aop是否打印返回信息 */
  showProxyPrint: boolean
}
