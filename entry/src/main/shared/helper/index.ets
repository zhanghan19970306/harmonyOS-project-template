import { promptAction } from "@kit.ArkUI"
import { pasteboard } from "@kit.BasicServicesKit"
import { fileIo, fileUri } from "@kit.CoreFileKit"
import { photoAccessHelper } from "@kit.MediaLibraryKit"
import fs from "@ohos.file.fs"
import { File } from "./model"

/** 选择图片 */
export const selectImage = async (maxSelectNumber: number = 1) => {
  const photoSelectOptions = new photoAccessHelper.PhotoSelectOptions()
  photoSelectOptions.MIMEType = photoAccessHelper.PhotoViewMIMETypes.IMAGE_TYPE // 过滤选择媒体文件类型为IMAGE
  photoSelectOptions.maxSelectNumber = maxSelectNumber // 选择媒体文件的最大数目

  const photoViewPicker = new photoAccessHelper.PhotoViewPicker()
  const photoSelectResult = await photoViewPicker.select(photoSelectOptions)

  return photoSelectResult.photoUris
}

/** 获取缓存零食目录 */
export const getFiles = (uris: string[]) => {

  const context = getContext()

  return uris.map(uri => {
    const fileUriObject = new fileUri.FileUri(uri)

    // 读取上面返回uri
    const file = fileIo.openSync(uri, fileIo.OpenMode.READ_ONLY)

    // 复制文件到缓存目录下
    fileIo.copyFileSync(file.fd, context.cacheDir + `/${fileUriObject.name}`)

    const fileInfo: File = {
      filename: fileUriObject.name,
      name: "image",
      uri: `internal://cache/${fileUriObject.name}`,
      type: fileUriObject.name.split(".")[1]
    }

    return fileInfo

  })

}

/** 获取文件上传副本 */
export const getCopyFilePath = (filePath: string) => {
  const paths = filePath.split("/")
  const _fileName = paths.pop()
  const cacheDir = getContext()
    .cacheDir
  // const fileType = filePath.split('.').pop() || 'png'
  const fileName = `${new Date().getTime()}_${_fileName}`
  const fullPath = cacheDir + "/" + fileName // 设置图片路径
  const file = fs.openSync(filePath, fs.OpenMode.READ_ONLY) // 打开图片
  fs.copyFileSync(file.fd, fullPath, fs.OpenMode.READ_ONLY) // 复制图片
  return `internal://cache/${fileName}`
}



// 将文案添加至剪切版本
export async function copyText(str: string, showToast = true) {
  const pasteboardData = pasteboard.createData(pasteboard.MIMETYPE_TEXT_PLAIN, str)
  const systemPasteboard = pasteboard.getSystemPasteboard()
  await systemPasteboard.setData(pasteboardData)
  if (showToast) {
    promptAction.showToast({ message: "复制成功" })
  }
}
