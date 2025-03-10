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

/** lazyForEach实体类 */
@Observed
export class LazyDataSource<T> implements IDataSource {
  private listeners: DataChangeListener[] = []
  private originDataArray: T[] = []

  constructor(data?: T[]) {
    data?.forEach(item => this.pushData(item))
  }

  public totalCount(): number {
    return this.originDataArray.length
  }

  public getData(index: number): T {
    return this.originDataArray[index]
  }

  public addData(index: number, data: T): void {
    this.originDataArray.splice(index, 0, data)
    this.notifyDataAdd(index)
  }

  public pushData(data: T | T[]): void {
    if (Array.isArray(data)) {
      data.forEach(item => {
        this.originDataArray.push(item)
        this.notifyDataAdd(this.originDataArray.length - 1)
      })
    } else {
      this.originDataArray.push(data)
      this.notifyDataAdd(this.originDataArray.length - 1)
    }
  }

  public deleteData(index: number): void {
    this.originDataArray.splice(index, 1)
    this.notifyDataDelete(index)
  }

  public clear(): void {
    const len = this.originDataArray.length
    this.originDataArray = []
    let i = len - 1
    while (i >= 0) {
      // 需要反向通知 删除对应索引
      this.notifyDataDelete(i--)
    }
  }

  public moveData(from: number, to: number): void {
    const temp: T = this.originDataArray[from]
    this.originDataArray[from] = this.originDataArray[to]
    this.originDataArray[to] = temp
    this.notifyDataMove(from, to)
  }

  // 该方法为框架侧调用，为LazyForEach组件向其数据源处添加listener监听
  registerDataChangeListener(listener: DataChangeListener): void {
    if (this.listeners.indexOf(listener) < 0) {
      this.listeners.push(listener)
    }
  }

  // 该方法为框架侧调用，为对应的LazyForEach组件在数据源处去除listener监听
  unregisterDataChangeListener(listener: DataChangeListener): void {
    const pos = this.listeners.indexOf(listener)
    if (pos >= 0) {
      console.info("remove listener")
      this.listeners.splice(pos, 1)
    }
  }

  // 通知LazyForEach组件需要重载所有子组件
  notifyDataReload(): void {
    this.listeners.forEach(listener => {
      listener.onDataReloaded()
    })
  }

  // 通知LazyForEach组件需要在index对应索引处添加子组件
  notifyDataAdd(index: number): void {
    this.listeners.forEach(listener => {
      listener.onDataAdd(index)
    })
  }

  // 通知LazyForEach组件在index对应索引处数据有变化，需要重建该子组件
  notifyDataChange(index: number): void {
    this.listeners.forEach(listener => {
      listener.onDataChange(index)
    })
  }

  // 通知LazyForEach组件需要在index对应索引处删除该子组件
  notifyDataDelete(index: number): void {
    this.listeners.forEach(listener => {
      listener.onDataDelete(index)
    })
  }

  // 通知LazyForEach组件将from索引和to索引处的子组件进行交换
  notifyDataMove(from: number, to: number): void {
    this.listeners.forEach(listener => {
      listener.onDataMove(from, to)
    })
  }
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
