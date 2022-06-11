// ログイン画面
$(function() {
  $('#login-form').submit(function() {
    const loginEmailValue = $('#email-form').val();
    const loginPasswordValue = $('#password-form').val();
    
    // emailが空のとき、エラー文を表示する
    if ( loginEmailValue == '') {
      $('#email-error-message').text('入力されていません');
      var errStatus = true;
    } else if ( loginEmailValue.length > 100 ) {
      $('#email-error-message').text('100文字以内で入力してください');
      var errStatus = true;
    } else {
      $('#email-error-message').text('');
    }

    // パスワードが空のとき、エラー文を表示する
    if ( loginPasswordValue == '' ) {
      $('#password-error-message').text('入力されていません');
      var errStatus = true;
    } else if ( loginPasswordValue.length < 6 || loginPasswordValue.length > 30 ) {
      $('#password-error-message').text('6文字以上、30文字以内で入力してください');
      var errStatus = true;
    } else {
      $('#password-error-message').text('');
    }

    if ( errStatus ) {
      return false;
    }
  });
});

// 新規登録画面
$(function() {
  $('#register-form').submit(function() {
    const registerNameValue = $('#users_name').val();
    const registerEmailValue = $('#users_email').val();
    const registerPasswordValue = $('#user_password').val();
    const registerPasswordConfirmValue = $('#user_password_confirm').val();
    
    // Nameが空のとき、エラー文を表示する
    if ( registerNameValue == '') {
      $('#name-error-message').text('入力されていません');
      var errStatus = true;
    } else if ( registerNameValue.length > 20 ) {
      $('#name-error-message').text('20文字以内で入力してください');
      var errStatus = true;
    } else {
      $('#name-error-message').text('');
    }

    // Emailが空のとき、エラー文を表示する
    if ( registerEmailValue == '') {
      $('#email-error-message').text('入力されていません');
      var errStatus = true;
    } else if ( registerEmailValue.length > 100 ) {
      $('#email-error-message').text('100文字以内で入力してください');
      var errStatus = true;
    } else {
      $('#email-error-message').text('');
    }

    // パスワードが空のとき、エラー文を表示する
    if ( registerPasswordValue == '') {
      $('#password-error-message').text('入力されていません');
      var errStatus = true;
    } else if ( registerPasswordValue.length < 6 || registerPasswordValue.length > 30 ) {
      $('#password-error-message').text('6文字以上、30文字以内で入力してください');
      var errStatus = true;
    } else if ( registerPasswordValue != registerPasswordConfirmValue ) {
      $('#password-error-message').text('パスワードと確認用の値が一致していません');
      var errStatus = true;
    } else {
      $('#password-error-message').text('');
    }

    // パスワード（確認用）が空のとき、エラー文を表示する
    if ( registerPasswordConfirmValue == '') {
      $('#password-confirm-error-message').text('入力されていません');
      var errStatus = true;
    } else if ( registerPasswordConfirmValue.length < 6 || registerPasswordConfirmValue.length > 30 ) {
      $('#password-confirm-error-message').text('6文字以上、30文字以内で入力してください');
      var errStatus = true;
    } else if ( registerPasswordValue != registerPasswordConfirmValue ) {
      $('#password-confirm-error-message').text('パスワードと確認用の値が一致していません');
      var errStatus = true;
    } else {
      $('#password-confirm-error-message').text('');
    }

    if ( errStatus ) {
      return false;
    }
  });
});

// パスワードリセット画面（email送信画面）
$(function() {
  $('#password-form').submit(function() {
    const passwordResetEmailValue = $('#users_email').val();
    
    // emailが空のとき、エラー文を表示する
    if ( passwordResetEmailValue == '') {
      $('#email-error-message').text('入力されていません');
      var errStatus = true;
    } else if ( passwordResetEmailValue.length > 100 ) {
      $('#email-error-message').text('100文字以内で入力してください');
      var errStatus = true;
    } else {
      $('#email-error-message').text('');
    }

    if ( errStatus ) {
      return false;
    }
  });
});

// パスワードリセット画面（パスワード編集画面）
$(function() {
  $('#password-reset-form').submit(function() {
    const resetPasswordValue = $('#reset_password').val();
    const resetPasswordConfirmValue = $('#reset_password_confirm').val();
    
    // パスワードが空のとき、エラー文を表示する
    if ( resetPasswordValue == '') {
      $('#password-error-message').text('入力されていません');
      var errStatus = true;
    } else if ( resetPasswordValue.length < 6 || resetPasswordValue.length > 30 ) {
      $('#password-error-message').text('6文字以上、30文字以内で入力してください');
      var errStatus = true;
    } else if ( resetPasswordValue != resetPasswordConfirmValue ) {
      $('#password-error-message').text('パスワードと確認用の値が一致していません');
      var errStatus = true;
    } else {
      $('#password-error-message').text('');
    }

    // パスワード（確認用）が空のとき、エラー文を表示する
    if ( resetPasswordConfirmValue == '') {
      $('#password-confirm-error-message').text('入力されていません');
      var errStatus = true;
    } else if ( resetPasswordConfirmValue.length < 6 || resetPasswordConfirmValue.length > 30 ) {
      $('#password-confirm-error-message').text('6文字以上、30文字以内で入力してください');
      var errStatus = true;
    } else if ( registerPasswordValue != resetPasswordConfirmValue ) {
      $('#password-confirm-error-message').text('パスワードと確認用の値が一致していません');
      var errStatus = true;
    } else {
      $('#password-confirm-error-message').text('');
    }

    if ( errStatus ) {
      return false;
    }
  });
});

// ユーザー編集画面
$(function() {
  $('#user-edit-form').submit(function() {
    const editNameValue = $('#edit_user_name').val();
    const editEmailValue = $('#edit_user_email').val();
    const editPasswordValue = $('#edit_user_password').val();
    const editPasswordConfirmValue = $('#edit_user_password_confirm').val();
    
    // Nameが空のとき、エラー文を表示する
    if ( editNameValue == '') {
      $('#name-error-message').text('入力されていません');
      var errStatus = true;
    } else if ( editNameValue.length > 20 ) {
      $('#name-error-message').text('20文字以内で入力してください');
      var errStatus = true;
    } else {
      $('#name-error-message').text('');
    }

    // Emailが空のとき、エラー文を表示する
    if ( editEmailValue == '') {
      $('#email-error-message').text('入力されていません');
      var errStatus = true;
    } else if ( editEmailValue.length > 100 ) {
      $('#email-error-message').text('100文字以内で入力してください');
      var errStatus = true;
    } else {
      $('#email-error-message').text('');
    }

    if ( editPasswordConfirmValue != '' && editPasswordValue.length < 6 || editPasswordValue.length > 30 ) {
      $('#password-error-message').text('6文字以上、30文字以内で入力してください');
      var errStatus = true;
    } else if ( editPasswordValue != editPasswordConfirmValue ) {
      $('#password-error-message').text('パスワードと確認用の値が一致していません');
      var errStatus = true;
    } else {
      $('#password-error-message').text('');
    }

    // パスワード（確認用）が空のとき、エラー文を表示する
    if ( editPasswordConfirmValue != '' && editPasswordConfirmValue.length < 6 || editPasswordConfirmValue.length > 30 ) {
      $('#password-confirm-error-message').text('6文字以上、30文字以内で入力してください');
      var errStatus = true;
    } else if ( editPasswordValue != editPasswordConfirmValue ) {
      $('#password-confirm-error-message').text('パスワードと確認用の値が一致していません');
      var errStatus = true;
    } else {
      $('#password-confirm-error-message').text('');
    }

    if ( errStatus ) {
      return false;
    }
  });
});