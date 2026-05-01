<template>
  <el-container class="main-container">
    <el-header class="header">
      <span class="logo">协同文档知识库</span>
      <div class="user-area">
        <span>{{ userStore.currentUser?.nickname || userStore.currentUser?.username }}</span>
        <el-button type="text" @click="logout">退出</el-button>
      </div>
    </el-header>
    <el-container class="body-container">
      <el-aside width="260px" class="aside">
        <DirTree @select-doc="handleSelectDoc" />
      </el-aside>
      <el-main class="main-content">
        <div class="search-bar">
          <el-input v-model="searchKey" placeholder="搜索文档..." prefix-icon="Search" clearable />
        </div>
        <div v-if="currentDocId" class="editor-area">
          <DocEditor :docId="currentDocId" />
        </div>
        <el-empty v-else description="请在左侧目录中选择文档" />
      </el-main>
    </el-container>
  </el-container>
</template>

<script setup>
import { ref } from 'vue'
import DirTree from '@/components/DirTree.vue'
import DocEditor from '@/components/DocEditor.vue'
import { useUserStore } from '@/stores/user'
import { useRouter } from 'vue-router'

const userStore = useUserStore()
const router = useRouter()
const currentDocId = ref(null)
const searchKey = ref('')

function handleSelectDoc(docId) {
  currentDocId.value = docId
}

function logout() {
  userStore.logout()
  router.push('/login')
}
</script>

<style scoped>
.header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  background: #545c64;
  color: white;
}
.aside {
  background: #f5f7fa;
  border-right: 1px solid #dcdfe6;
  overflow-y: auto;
}
.main-content {
  padding: 20px;
}
.search-bar {
  margin-bottom: 15px;
}
.editor-area {
  border: 1px solid #dcdfe6;
  border-radius: 4px;
}
</style>