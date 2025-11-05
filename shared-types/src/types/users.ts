export interface Users {
  id: string;    // primary key
  name: string;
  email: string;
  age?: string;
  address?: string;
  avatar_url?: string;
  created_at?: Date;
  updated_at?: Date;
  is_deleted?: boolean;
  deleted_at?: Date;
}
