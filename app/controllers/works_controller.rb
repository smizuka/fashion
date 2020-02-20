class WorksController < ApplicationController

  protect_from_forgery except: :search # searchアクションを除外

  def main

    user_state=[]
    annotations = Annotation.where(state: "working")
    #そのユーザーが取得した画像だけを取り出す
    edited = Edited.where(user_id: current_user.id)
    #annotaionのidだけを取り出す。
    edited_annotation_id = edited.map{|v| v.annotation_id}
    #userの情報を配列に入れる(@countが0のときはerrorになるかもしれないので除外)
    for annotation in annotations

      if edited_annotation_id.include?(annotation.id)

      else
        file_path = annotation.folder_name+"/"+annotation.path
        file_path = "http://118.27.2.176/~mizukami/"+ file_path
        user_state.push([annotation.id, current_user.id, file_path, annotation.information, annotation.folder_name, annotation.path])
      end
    end

    @count = user_state.length

    @user_state = user_state[0]
    # binding.pry

  end

  def annotation

    # user_state=[]
    annotations = Annotation.where(state: "unassigned")

    #working状態の画像の数を取得。viewファイルの表示・非表示に関わる
    @count = annotations.count

    #userの情報を配列に入れる(@countが0のときはerrorになるかもしれないので除外)
    if @count != 0
        #フォルダ名とファイル名を結合して、画像pathを取得する
        file_path =annotations[0].folder_name+"/"+annotations[0].path
        file_path = "http://118.27.2.176/~mizukami/"+ file_path
        #
        (@count == 1) ? ( next_file = "なし" ) : ( next_file =annotations[1].path)

         @user_state = [annotations[0].id, current_user.id, file_path,annotations[0].information,annotations[0].folder_name,annotations[0].path, next_file]
    else
      @user_state = []
    end

  end

  #戻るをしたときの操作
  def back

    edit = Edited.where(user_id: current_user.id)

    if edit.length != 1 || edit == nil
      redirect_to works_main_path
    else
      edit[-1].destroy
      redirect_to works_main_path
    end

  end

  def trim

    annotation = Annotation.find(params[:id])
    #annotationを作業状態にする
    if params[:category]== "p"
      #endのものは８分類の際に表示されないようにする
      annotation.update_attribute(:state, "end")
    else
      annotation.update_attribute(:state, "working")
    end

    redirect_to works_annotation_path
  end

  #アノテーションされたあとの結果
  def action

    results = [
      params["fashion"]["elegant"],
      params["fashion"]["romantic"],
      params["fashion"]["ethnic"],
      params["fashion"]["country"],
      params["fashion"]["active"],
      params["fashion"]["mannish"],
      params["fashion"]["modern"],
      params["fashion"]["sophisticate"]
    ]

    #nilを配列から削除する
    results.compact!

    if results.length != 8

      redirect_to works_main_path, info: 'チェック漏れがあります。'

    else

      edited = Edited.new
      edited.user_id = params["user_id"].to_i
      edited.annotation_id = params["annotation_id"].to_i
      edited.path = params["path"]
      edited.information = results.join(",")
      edited.save

      redirect_to works_main_path

    end

  end
end

