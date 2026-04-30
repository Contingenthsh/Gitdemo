<template>
  <div class="doc-editor">
    <div v-if="loading" class="loading">加载中...</div>
    <div v-else>
      <div class="editor-header">
        <el-input v-model="title" placeholder="文档标题" @blur="saveTitle" />
        <el-tag v-if="saving">保存中...</el-tag>
      </div>
      <div class="editor-container" v-if="editor">
        <div class="toolbar">
          <button @click="editor.chain().focus().toggleBold().run()" :class="{ 'is-active': editor.isActive('bold') }"><strong>B</strong></button>
          <button @click="editor.chain().focus().toggleItalic().run()" :class="{ 'is-active': editor.isActive('italic') }"><em>I</em></button>
          <button @click="editor.chain().focus().toggleUnderline().run()" :class="{ 'is-active': editor.isActive('underline') }"><u>U</u></button>
          <button @click="editor.chain().focus().toggleHeading({ level: 1 }).run()" :class="{ 'is-active': editor.isActive('heading', { level: 1 }) }">H1</button>
          <button @click="editor.chain().focus().toggleHeading({ level: 2 }).run()" :class="{ 'is-active': editor.isActive('heading', { level: 2 }) }">H2</button>
          <button @click="editor.chain().focus().toggleBulletList().run()" :class="{ 'is-active': editor.isActive('bulletList') }">列表</button>
          <button @click="editor.chain().focus().toggleOrderedList().run()" :class="{ 'is-active': editor.isActive('orderedList') }">编号</button>
          <button @click="editor.chain().focus().toggleBlockquote().run()" :class="{ 'is-active': editor.isActive('blockquote') }">引用</button>
          <button @click="editor.chain().focus().toggleCodeBlock().run()" :class="{ 'is-active': editor.isActive('codeBlock') }">代码块</button>
          <button @click="editor.chain().focus().setHorizontalRule().run()">分割线</button>
        </div>
        <editor-content :editor="editor" class="editor-content" />
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, watch, onBeforeUnmount } from 'vue'
import { useEditor, EditorContent } from '@tiptap/vue-3'
import StarterKit from '@tiptap/starter-kit'
import Underline from '@tiptap/extension-underline'
import Placeholder from '@tiptap/extension-placeholder'
import { getDocDetail, updateDoc } from '@/api/doc'
import { ElMessage } from 'element-plus'

const props = defineProps({ docId: Number })
const loading = ref(false)
const title = ref('')
const saving = ref(false)
let saveTimer = null

const editor = useEditor({
  extensions: [
    StarterKit,
    Underline,
    Placeholder.configure({ placeholder: '请输入文档内容...' })
  ],
  content: '',
  onUpdate: () => {
    clearTimeout(saveTimer)
    saveTimer = setTimeout(() => {
      if (props.docId && editor.value) {
        autoSave()
      }
    }, 2000)
  }
})

// 加载文档
watch(() => props.docId, async (id) => {
  if (!id || !editor.value) return
  loading.value = true
  try {
    const data = await getDocDetail(id)
    title.value = data.title
    editor.value.commands.setContent(data.content || '')
  } finally {
    loading.value = false
  }
}, { immediate: true })

async function autoSave() {
  if (!props.docId || !editor.value) return
  saving.value = true
  try {
    const html = editor.value.getHTML()
    await updateDoc(props.docId, { title: title.value, content: html })
  } catch (err) {
    ElMessage.error('自动保存失败')
  } finally {
    saving.value = false
  }
}

async function saveTitle() {
  if (!props.docId || !editor.value) return
  await updateDoc(props.docId, { title: title.value, content: editor.value.getHTML() })
  ElMessage.success('标题已保存')
}

onBeforeUnmount(() => {
  editor.value?.destroy()
})
</script>

<style scoped>
.doc-editor {
  background: white;
  padding: 8px;
}
.loading {
  padding: 20px;
  text-align: center;
}
.editor-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 8px;
}
.editor-container {
  border: 1px solid #dcdfe6;
  border-radius: 4px;
}
.toolbar {
  padding: 8px;
  border-bottom: 1px solid #e5e7eb;
  display: flex;
  gap: 4px;
  flex-wrap: wrap;
}
.toolbar button {
  padding: 4px 8px;
  border: 1px solid #d1d5db;
  border-radius: 4px;
  background: white;
  cursor: pointer;
  font-size: 14px;
}
.toolbar button:hover {
  background: #f3f4f6;
}
.toolbar button.is-active {
  background: #e5e7eb;
  border-color: #9ca3af;
}
.editor-content {
  padding: 12px;
  min-height: 400px;
  max-height: 600px;
  overflow-y: auto;
}
.editor-content :deep(.ProseMirror) {
  outline: none;
  min-height: 380px;
}
.editor-content :deep(p) {
  margin: 0.5em 0;
}
</style>