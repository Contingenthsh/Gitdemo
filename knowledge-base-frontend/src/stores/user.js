import { defineStore } from 'pinia'
import { ref } from 'vue'
import { login as apiLogin } from '@/api/user'

export const useUserStore = defineStore('user', () => {
  const token = ref(localStorage.getItem('token') || '')
  const currentUser = ref(null)

  async function loginAction(form) {
    const data = await apiLogin(form)
    token.value = data.token
    localStorage.setItem('token', data.token)
    currentUser.value = data.user
  }

  function logout() {
    token.value = ''
    localStorage.removeItem('token')
    currentUser.value = null
  }

  return { token, currentUser, loginAction, logout }
})