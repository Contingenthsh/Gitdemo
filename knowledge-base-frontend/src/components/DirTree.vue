<template>
  <div class="dir-tree-container">
    <div class="toolbar">
      <el-button type="primary" size="small" @click="openCreateDirDialog(null)">新建根目录</el-button>
    </div>
    <el-tree
      ref="treeRef"
      :data="treeData"
      :props="treeProps"
      node-key="id"
      highlight-current
      :expand-on-click-node="false"
      @node-click="onNodeClick"
      @node-contextmenu="onContextMenu"
    >
      <template #default="{ data }">
        <span class="tree-node">
          <el-icon v-if="data.type === 'dir'"><Folder /></el-icon>
          <el-icon v-else><Document /></el-icon>
          <span>{{ data.name }}</span>
        </span>
      </template>
    </el-tree>

    <!-- 右键菜单 -->
    <div
      v-if="contextMenu.visible"
      class="context-menu"
      :style="{ position: 'fixed', left: contextMenu.x+'px', top: contextMenu.y+'px' }"
    >
      <ul>
        <li v-if="contextMenu.data.type === 'dir'" @click="openCreateDirDialog(contextMenu.data)">新建子目录</li>
        <li v-if="contextMenu.data.type === 'dir'" @click="openCreateDocDialog(contextMenu.data)">新建文档</li>
        <li @click="renameNode(contextMenu.data)">重命名</li>
        <li @click="deleteNode(contextMenu.data)">删除</li>
      </ul>
    </div>

    <!-- 新建目录弹窗 -->
    <el-dialog v-model="dirDialog.visible" title="新建目录" width="400px">
      <el-input v-model="dirDialog.name" placeholder="目录名称" />
      <template #footer>
        <el-button @click="dirDialog.visible = false">取消</el-button>
        <el-button type="primary" @click="submitCreateDir">确定</el-button>
      </template>
    </el-dialog>

    <!-- 新建文档弹窗 -->
    <el-dialog v-model="docDialog.visible" title="新建文档" width="400px">
      <el-input v-model="docDialog.title" placeholder="文档标题" />
      <template #footer>
        <el-button @click="docDialog.visible = false">取消</el-button>
        <el-button type="primary" @click="submitCreateDoc">确定</el-button>
      </template>
    </el-dialog>

    <!-- 重命名弹窗 -->
    <el-dialog v-model="renameDialog.visible" title="重命名" width="400px">
      <el-input v-model="renameDialog.name" placeholder="新名称" />
      <template #footer>
        <el-button @click="renameDialog.visible = false">取消</el-button>
        <el-button type="primary" @click="submitRename">确定</el-button>
      </template>
    </el-dialog>
  </div>
</template>

<script setup>
import { ref, onMounted, reactive } from 'vue'
import { getDirTree, createDir, renameDir, deleteDir } from '@/api/dir'
import { createDoc, deleteDoc } from '@/api/doc'
import { ElMessage, ElMessageBox } from 'element-plus'

const emit = defineEmits(['select-doc'])
const treeData = ref([])
const treeProps = { children: 'children', label: 'name' }

const contextMenu = reactive({ visible: false, x: 0, y: 0, data: null })
function onContextMenu(event, data) {
  event.preventDefault()
  contextMenu.visible = true
  contextMenu.x = event.clientX
  contextMenu.y = event.clientY
  contextMenu.data = data
  document.addEventListener('click', () => { contextMenu.visible = false }, { once: true })
}

async function loadTree() {
  const res = await getDirTree()
  treeData.value = res
}
onMounted(loadTree)

function onNodeClick(data) {
  if (data.type === 'doc') {
    emit('select-doc', data.id)
  }
}

// ---- 新建目录 ----
const dirDialog = reactive({ visible: false, name: '', parent: null })
function openCreateDirDialog(parentData) {
  dirDialog.parent = parentData
  dirDialog.name = ''
  dirDialog.visible = true
  contextMenu.visible = false
}
async function submitCreateDir() {
  if (!dirDialog.name.trim()) return
  const parentId = dirDialog.parent ? dirDialog.parent.id : 0
  await createDir({ name: dirDialog.name.trim(), parentId })
  ElMessage.success('目录创建成功')
  dirDialog.visible = false
  loadTree()
}

// ---- 新建文档 ----
const docDialog = reactive({ visible: false, title: '', parentDir: null })
function openCreateDocDialog(parentDir) {
  docDialog.parentDir = parentDir
  docDialog.title = ''
  docDialog.visible = true
  contextMenu.visible = false
}
async function submitCreateDoc() {
  if (!docDialog.title.trim()) return
  await createDoc({ title: docDialog.title.trim(), folderId: docDialog.parentDir.id, content: '' })
  ElMessage.success('文档创建成功')
  docDialog.visible = false
  loadTree()
}

// ---- 重命名 ----
const renameDialog = reactive({ visible: false, name: '', node: null })
function renameNode(node) {
  renameDialog.node = node
  renameDialog.name = node.name
  renameDialog.visible = true
  contextMenu.visible = false
}
async function submitRename() {
  if (!renameDialog.name.trim()) return
  if (renameDialog.node.type === 'dir') {
    await renameDir(renameDialog.node.id, renameDialog.name.trim())
  }
  ElMessage.success('重命名成功')
  renameDialog.visible = false
  loadTree()
}

// ---- 删除节点 ----
async function deleteNode(node) {
  contextMenu.visible = false
  try {
    await ElMessageBox.confirm(`确定删除“${node.name}”吗？`, '警告', { type: 'warning' })
    if (node.type === 'dir') {
      await deleteDir(node.id)
    } else {
      await deleteDoc(node.id)
    }
    ElMessage.success('删除成功')
    loadTree()
    emit('select-doc', null)
  } catch (err) {
    // 取消
  }
}
</script>

<style scoped>
.toolbar {
  padding: 8px;
  border-bottom: 1px solid #dcdfe6;
}
.context-menu ul {
  list-style: none;
  background: white;
  border: 1px solid #ccc;
  padding: 5px 0;
  box-shadow: 2px 2px 8px rgba(0,0,0,0.2);
}
.context-menu li {
  padding: 5px 15px;
  cursor: pointer;
}
.context-menu li:hover {
  background: #ecf5ff;
}
</style>