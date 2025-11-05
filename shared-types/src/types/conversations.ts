export interface Conversations {
  id: string;    // primary key
  type: any;
  created_at?: Date;
  updated_at?: Date;
  is_deleted?: boolean;
  deleted_at?: Date;
  user_id?: string;    // foreign key
}
