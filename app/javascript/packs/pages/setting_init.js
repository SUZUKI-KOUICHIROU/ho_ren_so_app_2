import Vue from 'vue'
import XComponent from '../components/XComponent.vue'

document.addEventListener('DOMContentLoaded', () => {
  const appElement = document.getElementById('app')
  const userId = JSON.parse(appElement.getAttribute('data-user'))  
  const usersData = JSON.parse(appElement.getAttribute('data-users'))  

  new Vue({
    render: h => h(XComponent,{
      props: {
        userId: userId,
        usersInfo: usersData
      }
    })
  }).$mount(appElement)
})
