class WorksController < ApplicationController

  protect_from_forgery except: :search # searchアクションを除外

  #作業者に関係なく全員で８分類をするページ
  def main2
    user_state=[]
    annotations = Annotation.where(state: "unassigned")
    for annotation in annotations
      file_path = annotation.folder_name+"/"+annotation.path
      file_path = "https://nadera-annotation.s3-ap-northeast-1.amazonaws.com/"+ file_path
      user_state.push([annotation.id, current_user.id, file_path, annotation.information, annotation.folder_name, annotation.path])
    end

    @count = user_state.length
    @user_state = user_state[0]

  end

  #８分類で戻るを押した時
  def mainBack2
    annotations = Annotation.where(state: "end")
    #誰が作業済みしたかに関わらず、１つ戻る
    classifies = Classifier.all

    if classifies[-1] != nil
      classifies[-1].destroy
      annotations[-1].update_attribute(:state, "end")
      redirect_to works_main2_path
    else
      redirect_to works_main2_path, info: 'はじめの1枚です'
    end
  end

  #８分類されたあとの作業
  def action2

    if params["fashion"].nil?
      redirect_to works_main2_path, info: 'チェック漏れがあります。'
      return
    end

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

      ActiveRecord::Base.transaction do
        edited = Classifier.new
        edited.user_id = params["user_id"].to_i
        edited.annotation_id = params["annotation_id"].to_i
        edited.path = [params["folder_name"],params["path"]].join("/")
        edited.information = results.join(",")
        !edited.save

        annotation = Annotation.find(params["annotation_id"].to_i)
        annotation.update_attribute(:state, "end")

      end

      redirect_to works_main2_path
    end

  end
end

