class WorksController < ApplicationController

  protect_from_forgery except: :search # searchアクションを除外

  #作業者に関係なく全員で８分類をするページ
  def main

    annotation = Annotation.where(state: "working")[0]
    @count = [ annotation ].count

    if @count != 0
      file_path = annotation.folder_name+"/"+annotation.path
      file_path = "https://nadera-annotation.s3-ap-northeast-1.amazonaws.com/"+ file_path
      @user_state=[annotation.id, current_user.id, file_path, annotation.information, annotation.folder_name, annotation.path]
    else
      @user_state=[]
    end

  end

  #８分類で戻るを押した時
  def mainBack
    # classifies = Classifier.all
    annotations = Annotation.where(state: "end").order(updated_at: :desc).limit(1)
    classifies = Classifier.order(updated_at: :desc).limit(1)
    # binding.pry
    if classifies != nil
      ActiveRecord::Base.transaction do
        classifies[0].destroy
        annotations[0].update_attribute(:state, "working")
      end
    end

    redirect_to works_main_path
  end

  #８分類されたあとの作業
  def action

    if params["fashion"].nil?
      redirect_to works_main_path, info: 'チェック漏れがあります。'
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
      redirect_to works_main_path, info: 'チェック漏れがあります。'
    else

      ActiveRecord::Base.transaction do
        edited = Classifier.new
        edited.user_id = params["user_id"].to_i
        edited.annotation_id = params["annotation_id"].to_i
        edited.path = [params["folder_name"],params["path"]].join("/")
        edited.information = results.join(",")
        edited.save

        annotation = Annotation.find(params["annotation_id"].to_i)
        annotation.update_attribute(:state, "end")

      end

      redirect_to works_main_path
    end

  end

  def pass

    ActiveRecord::Base.transaction do
      annotation = Annotation.find(params["annotation_id"].to_i)
      edited = Classifier.new
      edited.user_id = 1
      edited.annotation_id = annotation.id
      edited.path = [annotation.folder_name,annotation.path].join("/")
      edited.information = "1,1,1,1,1,1,1,1"
      edited.save

      annotation.update_attribute(:state, "end")

    end

    redirect_to works_main_path  

  end
end

# <% flash.each do |key, value| %>
#   <div class="alert alert-<%= key %>" role="alert"><%= value %></div>
# <% end %>