module RecordsHelper

    def new_or_edit
      if action_name == 'new' || action_name == 'confirm' || action_name == 'create'
        confirm_records_path
      elsif action_name == 'edit'
        record_path
      end
    end 

end
