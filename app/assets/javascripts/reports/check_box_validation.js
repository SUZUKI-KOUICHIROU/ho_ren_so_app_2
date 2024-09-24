document.addEventListener('turbolinks:load', function() {
  // チェックボックスのinputタグを取得
  const checkBoxElements = Array.from(document.getElementsByClassName("check-box-option"));
  const errorMessage = "1つ以上の選択肢を選択してください。";

  checkBoxElements.forEach(m => {
    // エラーメッセージを、カスタムなものに変更
    m.setCustomValidity(errorMessage);

    // 各チェックボックスのチェックのオン・オフ時に、以下の処理が実行されるようにする
    m.addEventListener("change", () => {
      // 1つ以上チェックがされているかどうかを判定
      const isCheckedAtLeastOne = document.querySelector(".check-box-option:checked") !== null;

      // 1つもチェックがされていなかったら、すべてのチェックボックスを required にする
      // 加えて、エラーメッセージも変更する
      checkBoxElements.forEach(n => {
        n.required = !isCheckedAtLeastOne;
        n.setCustomValidity(isCheckedAtLeastOne ? "" : errorMessage);
      });
    });
  });
});
