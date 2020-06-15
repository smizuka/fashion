class WorksController < ApplicationController

  protect_from_forgery except: :search # searchアクションを除外

  #８分類するときの関数
  def main
    user_state=[]
    annotations = Annotation.where(state: "working")
    #そのユーザーが取得した画像だけを取り出す
    edited = Edited.where(user_id: current_user.id)
    #annotaionのidだけを取り出す。
    edited_annotation_id = edited.map{|v| v.annotation_id}


    #userの情報を配列に入れる(@countが0のときはerrorになるかもしれないので除外)
    for annotation in annotations


      # if annotation.path.include?("&")
      #   split_str = annotation.split("&")
      #   file_name = split_str[0]+CGI.unescape_html('&amp;')+split_str[1]
      # else
      #   file_name = annotation.path
      # end

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

  #作業者に関係なく全員で８分類をするページ
  def main2
    user_state=[]
    #枠アノテーションされた画像だけを取り出す
    annotations = Annotation.where(state: "working").select{|v| v.id > 1970}
    # annotations = Annotation.where(state: "working")
    #そのユーザーが取得した画像だけを取り出す

    # folder_list=["active_mask(1)","romantic_mask(1)","country_mask(1)","sophisticated_mask(1)","elegant_mask(1)","ethnic_mask(1)","modern_mask(1)","mannish_mask(1)"]
    folder_list=["futurism_horiuchi_mask(1)","modern_mask(1)"]

    edited_annotation_id = Classifier.all.map{|v| v.annotation_id}

    #userの情報を配列に入れる(@countが0のときはerrorになるかもしれないので除外)
    for annotation in annotations

      #フォルダ名のリストにある画像だけ表示する
      if folder_list.include?(annotation.folder_name)
        #８分類終わってない画像だけ表示する
        if edited_annotation_id.include?(annotation.id)
        else
          file_path = annotation.folder_name+"/"+annotation.path
          file_path = "http://118.27.2.176/~mizukami/"+ file_path
          user_state.push([annotation.id, current_user.id, file_path, annotation.information, annotation.folder_name, annotation.path])
        end

      end
    end

    @count = user_state.length

    @user_state = user_state[0]

  end


   #枠アノテーションをするときの関数
  def annotation

    # user_state=[]
    annotations = Annotation.where(state: "unassigned")

    # folder_list=["active_mask(1)","romantic_mask(1)","country_mask(1)","sophisticated_mask(1)","elegant_mask(1)","ethnic_mask(1)","modern_mask(1)","mannish_mask(1)"]
    folder_list=["futurism_horiuchi_mask(1)","modern_mask(1)"]

    #フォルダに含まれるものだけを選択する
    annotations = annotations.select{|v| folder_list.include?(v.folder_name)}

    #並び替える。
    annotations = annotations.sort
    #working状態の画像の数を取得。viewファイルの表示・非表示に関わる
    @count = annotations.count

    #userの情報を配列に入れる(@countが0のときはerrorになるかもしれないので除外)
    if @count != 0
        #フォルダ名とファイル名を結合して、画像pathを取得する
        file_path =annotations[0].folder_name+"/"+annotations[0].path
        file_path = "http://118.27.2.176/~mizukami/"+ file_path
        #
        (@count == 1) ? ( next_file = "なし" ) : ( next_file =annotations[1].path)

        informations = annotations[0].information.split(",")[0..3].join(",")

        @user_state = [annotations[0].id, current_user.id, file_path,informations,annotations[0].folder_name,annotations[0].path, next_file]
    else
      @user_state = []
    end

  end

  #枠決めで戻るをしたときの操作
  def annoBack

    #枠が決定したものとパスしたものを取り出す。
    annotations = Annotation.where(state: "working").or(Annotation.where(state: "end"))

    if annotations[-1] != nil
      annotations[-1].update_attribute(:state, "unassigned")
      annotations[-1].update_attribute(:information, "80,10,270,630,u")
      redirect_to works_annotation_path
    else
      redirect_to works_annotation_path
    end

  end

  #８分類でバックをしたとき
  def mainBack

    editeds = Edited.where(user_id: current_user.id)

    if editeds[-1] != nil
      editeds[-1].destroy
      redirect_to works_main_path
    else
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
      annotation.update_attribute(:information, params[:position])
    end

    redirect_to works_annotation_path
  end

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
      edited.path = [params["folder_name"],params["path"]].join("/")
      edited.information = results.join(",")
      edited.save

      redirect_to works_main_path
    end

  end

  #８分類でバックをしたとき
  def mainBack2

    #誰が作業済みしたかに関わらず、１つ戻る
    class_id = Classifier.all

    if class_id[-1] != nil
      class_id[-1].destroy
      redirect_to works_main2_path
    else
      redirect_to works_main2_path
    end
  end


  #８分類されたあとの作業
  def action2

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
      redirect_to works_main2_path, info: 'チェック漏れがあります。'
    else
      edited = Classifier.new
      edited.user_id = params["user_id"].to_i
      edited.annotation_id = params["annotation_id"].to_i
      edited.path = [params["folder_name"],params["path"]].join("/")
      edited.information = results.join(",")
      edited.save

      redirect_to works_main2_path
    end

  end
end

