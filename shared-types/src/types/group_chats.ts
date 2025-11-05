export interface Group_chats {
  id: string;    // primary key    // foreign key
  name?: string;
  creator: string;    // foreign key
}
