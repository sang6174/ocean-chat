export interface Accounts {
  id: string;    // primary key
  username: string;
  password: string;
  created_at?: Date;
  updated_at?: Date;
  is_deleted?: boolean;
  deleted_at?: Date;
  user_id?: string;    // foreign key
}
