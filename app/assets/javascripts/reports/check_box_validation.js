// Torbolinksを使用している場合ﾍﾟｰｼﾞの再読み込みや遷移時にJavascriptが実行されるようにturbolinks:loadｲﾍﾞﾝﾄ発生した際、関数実行
document.addEventListener('turbolinks:load', function () {
  // Turbolinksの影響を避けるためsetTimeoutを使って100ミリ秒の遅延を設けている
  setTimeout(() => {
    // 必須ﾁｪｯｸの対象ｸﾞﾙｰﾌﾟ取得 data-required=trueを持つ要素全てを取得
    // document:HTMLへｱｸｾｽする querySlectorAll:CSSｾﾚｸﾀに一致する全ての要素を取得するﾒｿｯﾄﾞ
    const requiredGroups = document.querySelectorAll('[data-required="true"]');

    // 各質問ｸﾞﾙｰﾌﾟを1つずつ処理 forEach:ﾙｰﾌﾟ処理
    requiredGroups.forEach(group => {
      // data-question-idの値を取得
      const questionId = group.dataset.questionId;

      // チェックボックスのみに限定して取得
      const checkBoxElements = Array.from(
        // querySelectorAllでinput[type="checkbox"]かつ[data-question-id]を持つ要素を対象
        group.querySelectorAll(`input[type="checkbox"][data-question-id="${questionId}"]`)
      );

      // ﾁｪｯｸﾎﾞｯｸｽが存在しない場合の処理
      if (checkBoxElements.length === 0) {
        // 警告を表示してその質問をｽｷｯﾌﾟ
        console.warn(`No checkboxes found for Question ID: ${questionId}`);
        return;
      }

      // 各ﾁｪｯｸﾎﾞｯｸｽへのﾊﾞﾘﾃﾞｰｼｮﾝ設定
      checkBoxElements.forEach(m => {

        // チェックボックスにエラーメッセージを設定
        m.setCustomValidity("1つ以上の選択肢を選択してください。");

        // ﾁｪｯｸﾎﾞｯｸｽ状態が変わった時に1つ以上のﾁｪｯｸがあるか確認
        m.addEventListener('change', () => {
          // some():配列の中に1つでも条件に合う要素があるか判定するﾒｿｯﾄﾞ あればtrueを返す
          // checkboxは任意の変数名 checked:HTMLのinput type=checkboxが持つﾌﾟﾛﾊﾟﾃｨ
          const isCheckedAtLeastOne = checkBoxElements.some(checkbox => checkbox.checked);

          checkBoxElements.forEach(n => {
            // isCheckedAtLeastOneがtureなら左辺はfalseとなる=requiredが解除される
            n.required = !isCheckedAtLeastOne;
            // 選択されていない場合requiredを有効化しﾒｯｾｰｼﾞ表示
            n.setCustomValidity(isCheckedAtLeastOne ? "" : "1つ以上の選択肢を選択してください。");
          });
        });
      });

      // 初期状態の確認とﾊﾞﾘﾃﾞｰｼｮﾝ設定 some():配列の中に1つでも条件に合う要素があるか判定するﾒｿｯﾄﾞ あればtrueを返す
      // checked:HTMLのinput type=checkboxが持つﾌﾟﾛﾊﾟﾃｨ
      const isCheckedAtLeastOne = checkBoxElements.some(checkbox => checkbox.checked);
      checkBoxElements.forEach(n => {
        n.required = !isCheckedAtLeastOne;
        n.setCustomValidity(isCheckedAtLeastOne ? "" : "1つ以上の選択肢を選択してください。");
      });
    });
  }, 100); // 100ms の遅延
});
