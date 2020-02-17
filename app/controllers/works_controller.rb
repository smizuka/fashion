class WorksController < ApplicationController

  protect_from_forgery except: :search # searchアクションを除外

  def main

    @user_state=[]
    annotations = Annotation.all

    #userの情報を配列に入れる(@countが0のときはerrorになるかもしれないので除外)
    for annotation in annotations
        file_path = annotation.folder_name+"/"+annotation.path
        file_path = "https://bard-annotation-data.s3-ap-northeast-1.amazonaws.com/"+ file_path
        @user_state = [annotation.id, current_user.id, file_path, annotation.information, annotation.folder_name, annotation.path]
    end


    # binding.pry
  end

  #戻るをしたときの操作
  def back

    #user_idに紐づいたeditedデータを取得する
    allo_data = Allocation.where(user_id: params["user_id"].to_i)

    allo_data = allo_data.select{ |i| i.state == "end" }

    # edit = Edited.find_by(annotation_id: params["annotation_id"].to_i)
    edit = Edited.where(user_id: params["user_id"].to_i)

    if edit != nil
      edit[-1].destroy
    end

    if allo_data.count != 0
      # アノテーションの状態を作業(state: 0)に変更する
      allo_data[-1].update_attribute(:state, "working")
    end

    redirect_to works_main_path

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

    edited = Edited.new
    edited.user_id = params["user_id"].to_i
    edited.annotation_id = params["annotation_id"].to_i
    edited.path = params["path"]
    edited.information = results.join(",")
    edited.save

    redirect_to works_main_path

  end
end
