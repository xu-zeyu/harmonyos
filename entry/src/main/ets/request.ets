import axios from '@ohos/axios'
import Prompt from '@system.prompt'

const service = axios.create({
  baseURL: 'http://192.168.31.200:7070', // ip得是电脑的网络ip
  timeout: 20000
})

service.interceptors.request.use(config => {
  // 暂时不需要做处理，后续会在此携带用户登陆的token
  return config
})

service.interceptors.response.use(
  response => {
    const result = response.data
    if (result.code===200) {
      return result.data
    } else {
      Prompt.showToast(result.message || '网络请求出错')
      return Promise.reject(new Error(result.message))
    }
  },
  error => {
    console.log('++res', JSON.stringify(error))
    Prompt.showToast(error.message || '网络请求出错')
    throw error
  }
)

export default service