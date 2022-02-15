### Permission Group Definition
resource "aviatrix_rbac_group" "rbac_group_100" {
  group_name  = "local-students"
  local_login = false
}

### Permission Group to Access Account Attachment 
resource "aviatrix_rbac_group_access_account_attachment" "rbac_group_access_account_attachment_1" {
  group_name          = aviatrix_rbac_group.rbac_group_100.group_name
  access_account_name = "all"
}


### Permission Group to User Attachment
resource "aviatrix_rbac_group_user_attachment" "rbac_group_user_attachment_1" {
  group_name = aviatrix_rbac_group.rbac_group_100.group_name
  user_name  = aviatrix_account_user.account_user_1.username
}


### Permission User Credentials
resource "aviatrix_account_user" "account_user_1" {
  username = "student"
  email    = var.ace_email
  password = var.ace_password
}

### Permission Group to Permission Set Attachment
resource "aviatrix_rbac_group_permission_attachment" "rbac_group_permission_attachment_1" {
  group_name      = aviatrix_rbac_group.rbac_group_100.group_name
  permission_name = "all_dashboard_write"
}

resource "aviatrix_rbac_group_permission_attachment" "rbac_group_permission_attachment_12" {
  group_name      = aviatrix_rbac_group.rbac_group_100.group_name
  permission_name = "all_useful_tools_write"
}

resource "aviatrix_rbac_group_permission_attachment" "rbac_group_permission_attachment_13" {
  group_name      = aviatrix_rbac_group.rbac_group_100.group_name
  permission_name = "all_troubleshoot_write"
}
