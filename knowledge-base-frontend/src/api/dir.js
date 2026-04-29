import request from './request'

export function getDirTree() {
  return request({ url: '/directory/tree', method: 'get' })
}

export function createDir(data) {
  return request({ url: '/directory', method: 'post', data })
}

export function renameDir(id, name) {
  return request({ url: `/directory/${id}`, method: 'put', data: { name } })
}

export function deleteDir(id) {
  return request({ url: `/directory/${id}`, method: 'delete' })
}