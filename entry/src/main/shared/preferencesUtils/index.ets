import { DEBUG } from "BuildProfile"
import { PreferencesUtils } from "./core"

if (DEBUG) {
  import("./helper")
    .then(moduleDefault => moduleDefault.proxyAopFn(PreferencesUtils))
}

export const preferencesUtils = new PreferencesUtils("qmai", [])
