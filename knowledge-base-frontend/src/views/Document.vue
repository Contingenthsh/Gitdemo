<template>
  <div class="main-container">
    <!-- 左侧目录树 -->
    <div class="sidebar">
      <div class="sidebar-header">
        <h3>📁 目录管理</h3>
      </div>
      <div class="directory-tree">
        <template v-for="node in directoryData" :key="node.id">
          <TreeNode :node="node" @select="handleSelectNode" />
        </template>
      </div>
      <div class="sidebar-actions">
        <button class="btn btn-primary" @click="showCreateModal('folder')">新建目录</button>
        <button class="btn btn-secondary" @click="showCreateModal('file')">新建文档</button>
      </div>
    </div>

    <!-- 中间编辑器 -->
    <div class="editor-container">
      <div class="editor-header">
        <div class="editor-title">
          <span>📄</span>
          <input 
            v-model="currentDocName" 
            class="doc-title" 
            placeholder="无标题文档"
          />
        </div>
        <button class="btn btn-primary" @click="saveDocument">💾 保存</button>
      </div>
      <div class="editor-toolbar">
        <button class="toolbar-btn" @click="formatText('bold')">B</button>
        <button class="toolbar-btn" @click="formatText('italic')">I</button>
        <button class="toolbar-btn" @click="insertList('ul')">• 列表</button>
      </div>
      <textarea 
        v-model="currentDocContent" 
        class="editor" 
        placeholder="开始编写你的文档..."
      ></textarea>
    </div>

    <!-- 右侧版本历史 -->
    <div class="version-panel">
      <div class="version-header">
        <h4>⏱️ 版本历史</h4>
      </div>
      <div class="version-list">
        <div 
          v-if="!selectedDoc?.versions?.length" 
          class="empty-tip"
        >暂无版本记录</div>
        <div 
          v-else 
          v-for="version in selectedDoc.versions" 
          :key="version.id"
          class="version-item"
          @click="restoreVersion(version)"
        >
          <div class="version-time">{{ version.time }}</div>
          <div class="version-author">作者：{{ version.author }}</div>
          <div class="version-preview">{{ version.preview }}</div>
        </div>
      </div>
    </div>

    <!-- 新建弹窗 -->
    <div class="modal" v-if="modalVisible">
      <div class="modal-content">
        <h4>{{ modalType === 'folder' ? '新建目录' : '新建文档' }}</h4>
        <input
          v-model="newNodeName"
          :placeholder="modalType === 'folder' ? '目录名称' : '文档名称'"
          class="modal-input"
        />
        <div class="modal-actions">
          <button class="btn btn-secondary" @click="closeModal">取消</button>
          <button class="btn btn-primary" @click="confirmCreate">确定</button>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, watch } from 'vue'

// 目录树子组件
const TreeNode = {
  props: ['node'],
  emits: ['select'],
  setup(props, { emit }) {
    const selected = ref(false)
    const handleClick = () => {
      selected.value = true
      emit('select', props.node)
    }
    return { selected, handleClick }
  },
  template: `
    <div class="tree-node">
      <div 
        class="node-item" 
        :class="{ selected }"
        @click="handleClick"
      >
        <span>{{ node.type === 'folder' ? '📁' : '📄' }}</span>
        <span>{{ node.name }}</span>
      </div>
      <div class="node-children" v-if="node.type === 'folder' && node.children?.length">
        <template v-for="child in node.children" :key="child.id">
          <TreeNode :node="child" @select="$emit('select', $event)" />
        </template>
      </div>
    </div>
  `
}

// 模拟数据
const directoryData = ref([
  {
    id: 1,
    name: '我的文档',
    type: 'folder',
    children: [
      {
        id: 2,
        name: '工作笔记',
        type: 'folder',
        children: [
          { id: 3, name: '项目需求.md', type: 'file', content: '# 项目需求\n系统功能说明...', versions: [] }
        ]
      },
      { id: 4, name: '个人笔记.md', type: 'file', content: '# 个人笔记\n学习记录...', versions: [] }
    ]
  }
])

const selectedDoc = ref(null)
const currentDocName = ref('')
const currentDocContent = ref('')

// 弹窗
const modalVisible = ref(false)
const modalType = ref('folder')
const newNodeName = ref('')

watch(selectedDoc, (newDoc) => {
  if (newDoc) {
    currentDocName.value = newDoc.name.replace('.md', '')
    currentDocContent.value = newDoc.content || ''
  } else {
    currentDocName.value = ''
    currentDocContent.value = ''
  }
}, { immediate: true })

const handleSelectNode = (node) => {
  if (node.type === 'file') {
    selectedDoc.value = node
  }
}

const showCreateModal = (type) => {
  modalType.value = type
  modalVisible.value = true
}
const closeModal = () => {
  modalVisible.value = false
  newNodeName.value = ''
}
const confirmCreate = () => {
  if (!newNodeName.value.trim()) return
  const newNode = {
    id: Date.now(),
    name: modalType.value === 'folder' ? newNodeName.value : `${newNodeName.value}.md`,
    type: modalType.value,
    children: modalType.value === 'folder' ? [] : undefined,
    content: modalType.value === 'file' ? '' : undefined,
    versions: modalType.value === 'file' ? [] : undefined
  }
  directoryData.value[0].children.push(newNode)
  closeModal()
}

const formatText = (type) => {
  const textarea = document.querySelector('.editor')
  const start = textarea.selectionStart
  const end = textarea.selectionEnd
  const selectedText = currentDocContent.value.substring(start, end)
  let formatted = ''
  if (type === 'bold') formatted = `**${selectedText || '粗体文本'}**`
  if (type === 'italic') formatted = `*${selectedText || '斜体文本'}*`
  currentDocContent.value = currentDocContent.value.substring(0, start) + formatted + currentDocContent.value.substring(end)
}
const insertList = (type) => {
  const prefix = type === 'ul' ? '- ' : '1. '
  currentDocContent.value += `\n${prefix}列表项`
}

const saveDocument = () => {
  if (!selectedDoc.value) return alert('请先选择文档')
  selectedDoc.value.name = `${currentDocName.value}.md`
  selectedDoc.value.content = currentDocContent.value
  const version = {
    id: Date.now(),
    time: new Date().toLocaleString(),
    author: '当前用户',
    preview: currentDocContent.value.substring(0, 50) + '...'
  }
  if (!selectedDoc.value.versions) selectedDoc.value.versions = []
  selectedDoc.value.versions.unshift(version)
  alert('保存成功！')
}

const restoreVersion = (version) => {
  if (confirm(`确定要恢复到 ${version.time} 的版本吗？当前内容将被覆盖。`)) {
    currentDocContent.value = version.preview.replace('...', '')
    alert('版本已恢复！')
  }
}
</script>

<style scoped>
* {
  margin: 0;
  padding: 0;
  box-sizing: border-box;
}
.main-container {
  display: flex;
  height: 100vh;
  background-color: #1e1e1e;
  color: #d4d4d4;
}

.sidebar {
  width: 280px;
  background-color: #252526;
  border-right: 1px solid #3e3e42;
  display: flex;
  flex-direction: column;
  padding: 10px;
}
.sidebar-header {
  padding: 10px;
  border-bottom: 1px solid #3e3e42;
  margin-bottom: 10px;
}
.sidebar-header h3 {
  color: #ffffff;
  font-size: 16px;
}
.directory-tree {
  flex: 1;
  overflow-y: auto;
  padding: 5px;
}
.tree-node {
  margin: 4px 0;
}
.node-item {
  padding: 6px 8px;
  border-radius: 4px;
  cursor: pointer;
  display: flex;
  align-items: center;
  gap: 6px;
}
.node-item:hover {
  background-color: #2a2d2e;
}
.node-item.selected {
  background-color: #094771;
}
.node-children {
  margin-left: 18px;
  border-left: 1px dotted #3e3e42;
  padding-left: 8px;
}
.sidebar-actions {
  padding: 10px;
  border-top: 1px solid #3e3e42;
  display: flex;
  gap: 8px;
}

.editor-container {
  flex: 1;
  display: flex;
  flex-direction: column;
}
.editor-header {
  padding: 10px 15px;
  background-color: #252526;
  border-bottom: 1px solid #3e3e42;
  display: flex;
  justify-content: space-between;
  align-items: center;
}
.doc-title {
  background: transparent;
  border: none;
  color: #ffffff;
  font-size: 16px;
  outline: none;
  padding: 4px 8px;
}
.editor-toolbar {
  padding: 8px 15px;
  background-color: #2d2d30;
  border-bottom: 1px solid #3e3e42;
  display: flex;
  gap: 10px;
}
.toolbar-btn {
  background: transparent;
  border: none;
  color: #d4d4d4;
  padding: 6px 10px;
  border-radius: 4px;
  cursor: pointer;
}
.toolbar-btn:hover {
  background-color: #3c3c3c;
}
.editor {
  flex: 1;
  padding: 20px;
  background-color: #1e1e1e;
  color: #d4d4d4;
  border: none;
  outline: none;
  font-size: 15px;
  line-height: 1.6;
  resize: none;
}

.version-panel {
  width: 250px;
  background-color: #252526;
  border-left: 1px solid #3e3e42;
  display: flex;
  flex-direction: column;
}
.version-header {
  padding: 10px;
  border-bottom: 1px solid #3e3e42;
}
.version-header h4 {
  color: #ffffff;
  font-size: 14px;
}
.version-list {
  flex: 1;
  overflow-y: auto;
  padding: 10px;
}
.version-item {
  padding: 10px;
  background-color: #2d2d30;
  border-radius: 4px;
  margin-bottom: 8px;
  cursor: pointer;
}
.version-item:hover {
  border: 1px solid #0e639c;
}
.version-time {
  font-size: 11px;
  color: #858585;
  margin-bottom: 4px;
}
.version-author {
  font-size: 12px;
  color: #d4d4d4;
}
.version-preview {
  font-size: 11px;
  color: #858585;
  margin-top: 4px;
  white-space: nowrap;
  overflow: hidden;
  text-overflow: ellipsis;
}
.empty-tip {
  color: #858585;
  text-align: center;
  margin-top: 20px;
}

.modal {
  position: fixed;
  top: 0;
  left: 0;
  width: 100%;
  height: 100%;
  background-color: rgba(0,0,0,0.5);
  display: flex;
  align-items: center;
  justify-content: center;
  z-index: 1000;
}
.modal-content {
  background-color: #252526;
  border: 1px solid #3e3e42;
  border-radius: 8px;
  padding: 20px;
  width: 300px;
}
.modal-content h4 {
  color: #ffffff;
  margin-bottom: 15px;
}
.modal-input {
  width: 100%;
  padding: 8px 10px;
  background-color: #3c3c3c;
  border: 1px solid #3e3e42;
  border-radius: 4px;
  color: #ffffff;
  margin-bottom: 15px;
}
.modal-actions {
  display: flex;
  justify-content: flex-end;
  gap: 10px;
}

.btn {
  padding: 6px 12px;
  border: none;
  border-radius: 4px;
  cursor: pointer;
  font-size: 13px;
}
.btn-primary {
  background-color: #0e639c;
  color: white;
}
.btn-secondary {
  background-color: #3c3c3c;
  color: white;
}
</style>