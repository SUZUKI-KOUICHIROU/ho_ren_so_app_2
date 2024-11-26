document.addEventListener('turbolinks:load', function() {
  // 各質問グループごとにバリデーションを設定
  const questionGroups = document.querySelectorAll('.question-group');

  questionGroups.forEach(group => {
    // 各グループ内のチェックボックスを取得
    const checkBoxElements = group.querySelectorAll('.check-box-option');
    const errorMessage = "1つ以上の選択肢を選択してください。";

    // グループ内の各チェックボックスに対して処理
    checkBoxElements.forEach(checkbox => {
      // 各チェックボックスにrequiredを明示的に設定
      checkbox.required = true;
      checkbox.setCustomValidity(errorMessage);

      // チェックボックスの変更イベント
      checkbox.addEventListener("change", () => {
        // 同じグループ内で1つ以上チェックされているか確認
        const isCheckedAtLeastOne = 
          group.querySelector(".check-box-option:checked") !== null;

        // グループ内の各チェックボックスのrequiredとエラーメッセージを更新
        checkBoxElements.forEach(cb => {
          cb.required = !isCheckedAtLeastOne;
          cb.setCustomValidity(isCheckedAtLeastOne ? "" : errorMessage);
        });
      });
    });
  });
});