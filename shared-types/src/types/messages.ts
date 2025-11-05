export interface Messages {
  id: string;    // primary key
  type?: string;
  data?: Record<string, any>;
  created_at?: Date;
  updated_at?: Date;
  is_deleted?: boolean;
  deleted_at?: Date;
  sender_id?: string;    // foreign key
  conversation_id?: string;    // foreign key
}
