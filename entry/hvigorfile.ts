import { getNode } from "@ohos/hvigor"
import { hapTasks, OhosAppContext, OhosHapContext, OhosPluginId } from "@ohos/hvigor-ohos-plugin";

/**
 * 动态的给entryAbility中的label添加上Mode，能够有效在手机上区分当前的环境。
 */
const entryNode = getNode(__filename);
entryNode.afterNodeEvaluate(node => {
    const rootNode = node.getParentNode()
    const appContext = rootNode.getContext(OhosPluginId.OHOS_APP_PLUGIN) as OhosAppContext;
    const buildMode = appContext.getBuildMode()

    const hapContext = node.getContext(OhosPluginId.OHOS_HAP_PLUGIN) as OhosHapContext;
    const moduleName = hapContext.getModuleName()

    if (buildMode.startsWith("custom_") && moduleName === "entry") {
        const moduleJsonOpt = hapContext.getModuleJsonOpt();
        const entryAbilityIdx = moduleJsonOpt['module']['abilities'].findIndex(item => item.name === "EntryAbility")
        if (entryAbilityIdx >= 0) {
            const mode = buildMode.replace("custom_", "")
            moduleJsonOpt['module']['abilities'][entryAbilityIdx].label += `_${mode}`
        }
        hapContext.setModuleJsonOpt(moduleJsonOpt);
    }
})

export default {
    system: hapTasks, /* Built-in plugin of Hvigor. It cannot be modified. */
    plugins: []         /* Custom plugin to extend the functionality of Hvigor. */
}
