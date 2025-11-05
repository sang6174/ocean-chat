export interface Devices {
  id: string;    // primary key
  device_code?: string;
  device_name?: string;
  created_at?: Date;
  updated_at?: Date;
  is_deleted?: boolean;
  deleted_at?: Date;
  user_id?: string;    // foreign key
}
