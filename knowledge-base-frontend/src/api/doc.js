import request from './request'

export function createDoc(data) {
  return request({ url: '/document', method: 'post', data })
}

export function getDocDetail(id) {
  return request({ url: `/document/${id}`, method: 'get' })
}

export function updateDoc(id, data) {
  return request({ url: `/document/${id}`, method: 'put', data })
}

export function deleteDoc(id) {
  return request({ url: `/document/${id}`, method: 'delete' })
}