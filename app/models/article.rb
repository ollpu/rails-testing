class Article < ActiveRecord::Base
  
  #Return a formatted date from an article
  def get_date
    date = created_at.to_date.strftime("Julkaistu %-d.%-m.%Y")
    if updated_at != created_at
      date += updated_at.to_date.strftime(" ja päivitetty viimeksi %-d.%-m.%Y.")
    else
      date += "."
    end
  end
end
