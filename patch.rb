diff --git a/lib/searchlogic/named_scopes/conditions.rb b/lib/searchlogic/named_scopes/conditions.rb
index 31d0643..c0c1d8e 100644
--- a/lib/searchlogic/named_scopes/conditions.rb
+++ b/lib/searchlogic/named_scopes/conditions.rb
@@ -30,7 +30,9 @@ module Searchlogic
       BOOLEAN_CONDITIONS = {
         :null => [:nil],
         :not_null => [:not_nil],
-        :empty => []
+        :empty => [],
+        :blank => [],
+        :not_blank => [:present]
       }
       
       CONDITIONS = {}
@@ -117,6 +119,10 @@ module Searchlogic
             {:conditions => "#{table_name}.#{column} IS NOT NULL"}
           when "empty"
             {:conditions => "#{table_name}.#{column} = ''"}
+          when "blank"
+            {:conditions => "#{table_name}.#{column} = '' OR #{table_name}.#{column} IS NULL"}
+          when "not_blank"
+            {:conditions => "#{table_name}.#{column} != '' OR #{table_name}.#{column} IS NOT NULL"}
           end
           
           named_scope("#{column}_#{condition}".to_sym, scope_options)
diff --git a/spec/named_scopes/conditions_spec.rb b/spec/named_scopes/conditions_spec.rb
index 6f71a4c..e8b0985 100644
--- a/spec/named_scopes/conditions_spec.rb
+++ b/spec/named_scopes/conditions_spec.rb
@@ -93,6 +93,16 @@ describe "Conditions" do
       ["bjohnson", ""].each { |username| User.create(:username => username) }
       User.username_empty.all.should == User.find_all_by_username("")
     end
+    
+    it "should have blank" do
+      ["bjohnson", "", nil].each { |username| User.create(:username => username) }
+      User.username_blank.all.should == User.all(:conditions => "username IS NULL OR username = ''")
+    end
+    
+    it "should have not blank" do
+      ["bjohnson", "", nil].each { |username| User.create(:username => username) }
+      User.username_not_blank.all.should == User.all(:conditions => "username IS NOT NULL OR username != ''")      
+    end
   end
   
   context "any and all conditions" do