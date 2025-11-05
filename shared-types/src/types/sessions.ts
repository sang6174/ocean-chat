export interface Sessions {
  id: string;    // primary key
  access_token: string;
  refresh_token: string;
  is_active?: boolean;
  last_login?: Date;
  created_at?: Date;
  expired_at?: Date;
  account_id?: string;    // foreign key
  device_id?: string;    // foreign key
  user_id?: string;    // foreign key
}
