import { preferences } from "@kit.ArkData"
import { CryptoJS } from "@ohos/crypto-js"
import {
  DebugOptions,
  GetPreferenceKey,
  GetPreferenceValue,
  GetPreferenceValueDefault,
  PreferenceScope
} from "./model"

export class PreferencesUtils<S extends PreferenceScope> {
  private name: S
  private iv = "zwd810D1ad"
  private encryptedKeys: Set<GetPreferenceKey<S>>

  constructor(name: S, encryptedKeys: GetPreferenceKey<S>[] = []) {
    this.name = name
    this.encryptedKeys = new Set(encryptedKeys)
  }

  // 设置数据
  async set<K extends GetPreferenceKey<S>>(key: K, value: GetPreferenceValue<S, K>) {
    const pref = await this._getPref()
    const finalValue = this.encryptedKeys.has(key) ? this._encrypt(value) : value
    await pref.put(key, finalValue)
    await pref.flush()
    return true
  }

  // 获取数据
  async get<K extends GetPreferenceKey<S>,
  T extends GetPreferenceValue<S, K>,
  D extends GetPreferenceValueDefault<T>>(key: K,
    defaultValue: D, debugOptions?: DebugOptions) {
    try {
      const pref = await this._getPref()
      const value = await pref.get(key, defaultValue as preferences.ValueType)
      const finalValue = this.encryptedKeys.has(key) ? this._decrypt(value as string) : value
      return finalValue as T
    } catch (e) {
      return defaultValue
    }
  }

  // 删除数据
  async delete<K extends GetPreferenceKey<S>>(key: K): Promise<boolean>;

  async delete<K extends GetPreferenceKey<S>>(key: K[]): Promise<boolean>;

  async delete<K extends GetPreferenceKey<S>>(key: K | K[]) {
    const pref = await this._getPref()

    if (Array.isArray(key)) {
      await Promise.all(key.map(item => pref.delete(item)))
    } else {
      await pref.delete(key)
    }

    await pref.flush()

    return true
  }

  // 是否存在某个key
  async has<K extends GetPreferenceKey<S>>(key: K): Promise<boolean>;

  async has<K extends GetPreferenceKey<S>>(key: K[]): Promise<boolean>;

  async has<K extends GetPreferenceKey<S>>(key: K | K[]) {
    const pref = await this._getPref()

    if (Array.isArray(key)) {
      const results = await Promise.all(key.map(item => pref.has(item)))
      return results.every(result => result)
    }

    return await pref.has(key)
  }

  private _getPref() {
    const context = getContext(this)
    return preferences.getPreferences(context, { name: this.name })
  }

  // 实现加密逻辑
  private _encrypt<K extends GetPreferenceKey<S>>(value: GetPreferenceValue<S, K>) {
    return CryptoJS.AES.encrypt(JSON.stringify(value), this.iv)
      .toString()
  }

  // 实现解密逻辑
  private _decrypt<K extends GetPreferenceKey<S>>(value: string) {
    return JSON.parse(CryptoJS.AES.decrypt(value, this.iv)
      .toString(CryptoJS.enc.Utf8)) as GetPreferenceValue<S, K>
  }
}
