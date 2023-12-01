var image_enable = [];

// プレビュー画像の削除
function remove_preview(id) {
	var preview = document.getElementById(`preview${id}`);
  var hinput = document.querySelector('#hiddenInput');
	
	preview.remove();
	image_enable[id] = false;
	hinput.value = image_enable;
}
// プレビュー画像のインデックス取得
function getFileIndexByName(fileList, fileName) {
  for (var i = 0; i < fileList.length; i++) {
    if (fileList[i].name === fileName) {
      return i; // ファイル名にマッチする要素のインデックスを返す
    }
  }
  return (-1); // ファイル名が見つからない場合は-1を返す
}
// プレビュー画像の作成・表示
function preview_images(input) {
  var preview = document.querySelector('.images_area');
	var hinput = document.querySelector('#hiddenInput');

  preview.innerHTML = ''; // プレビューエリアを一旦空にする
	image_enable.length = 0;

  if (input.files && input.files.length > 0) {
		for (var i = 0; i < input.files.length; i++) {
			var file = input.files[i];
      var reader = new FileReader();
			reader.file = file;
			
      reader.onload = function (e) {
				var idnum = getFileIndexByName(input.files, this.file.name);

        // ファイル名のインデックスチェック
        if (idnum != (-1)){
          // 画像表示タグの作成
          var area = document.createElement("div");
          area.className = 'images_preview'
          area.id = "preview" + idnum;
          preview.appendChild(area);
          // プレビュー画像の表示
          var img = document.createElement("img");
          img.src = e.target.result;
          img.width = 150;
          img.height = 150;
          area.appendChild(img);
          // 取り消しボタンの表示
          var button = document.createElement("button");
          button.innerText = "×";
          button.id = "remove_preview" + idnum;
          button.setAttribute("data-toggle", "tooltip");
          button.setAttribute("title", "ファイルを取り除く");
          button.setAttribute("onclick", `remove_preview(${idnum})`);
          area.appendChild(button);
        }
      };
      reader.readAsDataURL(file);
			image_enable[i] = true;
    }
		hinput.value = image_enable;
  }
}