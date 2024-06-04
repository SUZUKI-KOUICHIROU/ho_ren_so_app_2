<template>
  <div class="mt-3 mr-5 ml-4">
    <h1 class="text-center">ユーザー一覧</h1>
    <div class="table-header">
      <div class="member-name">氏名</div>
      <div class="member-name">権限</div>
      <div class="project-member-action">アクション</div>
    </div>
    <div class="table-body">
      <div v-for="user in usersInfo" :key="user.id">
        <div class="table-line">
          <div class="member-name">{{ user.name }}</div>
          <div class="member-name">{{ user.admin ? '管理者' : '一般ユーザー' }}</div>  
          <div class="project-member-action">
            <span class="btn" :class="user.admin ? 'btn-success' : 'btn-danger'" @click="updateAdmin(userId.id, user.id, !user.admin)" >  
              {{ user.admin ? '一般ユーザーにする' : '管理者にする' }}
            </span>
          </div>
        </div>
      </div>
    </div>    
  </div>
</template>

<script>
export default {
  props: {
    userId: {
      required: true
    },
    usersInfo: {
      type: Array,
      required: true
    }
  },
  methods: {
    updateAdmin(userId, adminId, adminFlag) {
      const url = `/users/${userId}/set_admin/${adminId}`;      
      const data = {
        user: {
          admin: adminFlag
        }
      };

      fetch(url, {
        method: 'PATCH',
        headers: {
          'Content-Type': 'application/json',
          'X-CSRF-Token': document.querySelector('[name="csrf-token"]').content
        },
        body: JSON.stringify(data)
      })
        .then(response => response.json())
        .then(data => {
          if (data.status === 'SUCCESS') {
            alert(`管理者権限を変更しました。`);
            if ( !adminFlag && (userId == adminId)) {
              location.href = `/users/${userId}/projects`;
            } else {              
              location.reload();
            }
          } else {
            alert('管理者権限の更新に失敗しました。');
          }
        })
        .catch(error => console.error('Error:', error));
    }
  }
}
</script>

<style scoped>
p {
  font-size: 2em;
  text-align: center;
}
</style>