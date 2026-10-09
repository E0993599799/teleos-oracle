export type EdEmailFileCategory = 'pdf' | 'image' | 'document' | 'other'

export interface EdEmailSearchFilters {
  dateFrom?: string
  dateTo?: string
  sender?: string
  recipient?: string
  subjectKeyword?: string
  hasAttachment?: boolean
  fileType?: EdEmailFileCategory
  importedStatus?: 'imported' | 'not_imported' | 'all'
  cursor?: string
  limit?: number
}

export interface EdEmailAttachmentSummary {
  partId: string
  filename: string
  mimeType: string
  sizeBytes: number
  category: EdEmailFileCategory
}

export interface EdEmailSearchResultItem {
  gmailMessageId: string
  gmailThreadId: string | null
  uid: number
  receivedAt: string | null
  sentAt: string | null
  sender: string
  recipients: string[]
  subject: string
  snippet: string
  attachmentCount: number
  attachments: EdEmailAttachmentSummary[]
  imported: boolean
  importedAt: string | null
}

export interface EdEmailDetail extends EdEmailSearchResultItem {
  bodyPlain: string | null
  bodyHtml: string | null
}

export function classifyFileCategory(mimeType: string, filename: string): EdEmailFileCategory {
  const lowerMime = (mimeType || '').toLowerCase()
  const lowerName = (filename || '').toLowerCase()
  if (lowerMime === 'application/pdf' || lowerName.endsWith('.pdf')) return 'pdf'
  if (lowerMime.startsWith('image/')) return 'image'
  if (
    lowerMime.includes('word') ||
    lowerMime.includes('officedocument') ||
    lowerMime.includes('excel') ||
    lowerMime.includes('spreadsheet') ||
    /\.(docx?|xlsx?|pptx?|csv)$/.test(lowerName)
  ) {
    return 'document'
  }
  return 'other'
}
