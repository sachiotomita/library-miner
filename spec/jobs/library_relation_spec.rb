require 'rails_helper'

RSpec.describe LibraryRelation, type: :model do
  describe '全件/クリア/差分モード確認' do
    context 'クリアモードの場合' do
      before do
        t1 = create(:project,
                    is_incomplete: false)
        create(:project_dependency,
               library_name: 'test_not_relation',
               project_from_id: t1.id,
               project_to_id: 1000)
        LibraryRelation.new.perform(mode: 'clear')
      end

      it '紐付けテーブルの内容が初期化されること' do
        expect(Project.all[0].is_incomplete).to eq true
        expect(ProjectDependency.all[0].project_to_id).to eq nil
      end
    end

    context '差分モードの場合' do
      before do
        t1 = create(:project,
                    is_incomplete: false)
        create(:project_dependency,
               library_name: 'test_not_relation',
               project_from_id: t1.id,
               project_to_id: 1000)
        LibraryRelation.new.perform(mode: 'diff')
      end

      it '紐付けテーブルの内容が初期化されないこと' do
        expect(Project.all[0].is_incomplete).to eq false
        expect(ProjectDependency.all[0].project_to_id).to eq 1000
      end
    end
  end

  describe 'ライブラリ紐付け確認' do
    context '過去に一度でも取り込まれたことがあるRubyGemsライブラリである場合' do
      before do
        @t1 = create(:input_project,
                     github_item_id: 100,
                     name: 'test',
                     full_name: 'owner/test')
        create(:input_library,
               input_project_id: @t1.id,
               name: 'test')
        @t2 = create(:project,
                     id: 10,
                     is_incomplete: true,
                     github_item_id: 99,
                     name: 'parent_test')
        @t3 = create(:project,
                     id: 11,
                     is_incomplete: true,
                     github_item_id: 100,
                     name: 'test')
        @pd1 = create(:project_dependency,
                      library_name: 'test',
                      project_from_id: @t2.id,
                      project_to_id: nil)
        LibraryRelation.new.perform(mode: 'diff')
      end
      it 'ライブラリ名を元にgithub_item_idを取得し,Projectと紐付けられること' do
        result = ProjectDependency.find(@pd1.id)

        expect(result.project_to_id).to eq @t3.id
      end
    end

    context 'LibraryMinerでの収集は行っていないがRubyGems'\
      '初回情報格納によりRubyGemsの情報が取得できた場合' do
      before do
        @t2 = create(:project,
                     id: 10,
                     is_incomplete: true,
                     github_item_id: 99,
                     full_name: 'owner/parent_test',
                     name: 'parent_test')
        @t3 = create(:project,
                     id: 11,
                     is_incomplete: true,
                     github_item_id: nil,
                     full_name: 'owner/test',
                     name: 'test')
        @pd1 = create(:project_dependency,
                      library_name: 'test',
                      project_from_id: @t2.id,
                      project_to_id: nil)
      end

      context 'rubygemsのhomepage_uriにgithubへのURLが格納されている場合' do
        before do
          create(:input_library,
                 input_project_id: nil,
                 homepage_uri: 'http://github.com/owner/test',
                 source_code_uri: nil,
                 name: 'test')
          LibraryRelation.new.perform(mode: 'diff')
        end
        it 'URLから取得したfull_nameを元にgithub_item_idを取得し,Projectと紐付けられること' do
          result = ProjectDependency.find(@pd1.id)

          expect(result.project_to_id).to eq @t3.id
        end
      end

      context 'rubygemsのsource_code_uriにgithubへのURLが格納されている場合' do
        before do
          create(:input_library,
                 input_project_id: nil,
                 homepage_uri: nil,
                 source_code_uri: 'http://github.com/owner/test',
                 name: 'test')
          LibraryRelation.new.perform(mode: 'diff')
        end

        it 'URLから取得したfull_nameを元にgithub_item_idを取得し,Projectと紐付けられること' do
          result = ProjectDependency.find(@pd1.id)

          expect(result.project_to_id).to eq @t3.id
        end
      end
    end

    context '上記条件以外の場合' do
      before do
        @t2 = create(:project,
                     id: 10,
                     is_incomplete: true,
                     github_item_id: 99,
                     full_name: 'owner/parent_test',
                     name: 'parent_test')
        @t3 = create(:project,
                     id: 11,
                     is_incomplete: true,
                     github_item_id: nil,
                     full_name: 'owner/test',
                     stargazers_count: 100,
                     name: 'test')
        @t4 = create(:project,
                     id: 12,
                     is_incomplete: true,
                     github_item_id: nil,
                     full_name: 'owner2/test',
                     stargazers_count: 102,
                     name: 'test')
        @t5 = create(:project,
                     id: 13,
                     is_incomplete: true,
                     github_item_id: nil,
                     full_name: 'owner3/test',
                     stargazers_count: 101,
                     name: 'test')

        @pd1 = create(:project_dependency,
                      library_name: 'test',
                      project_from_id: @t2.id,
                      project_to_id: nil)
        LibraryRelation.new.perform(mode: 'diff')
      end

      it 'ライブラリ名からProjectを検索し、スターが一番多いものを紐付け対象とされること' do
        result = ProjectDependency.find(@pd1.id)

        expect(result.project_to_id).to eq @t4.id
      end
    end

    context 'いずれの紐付けも失敗した場合' do
      before do
        @t2 = create(:project,
                     id: 10,
                     is_incomplete: true,
                     github_item_id: 99,
                     full_name: 'owner/parent_test',
                     name: 'parent_test')
        @t3 = create(:project,
                     id: 11,
                     is_incomplete: true,
                     github_item_id: nil,
                     full_name: 'owner/test2',
                     stargazers_count: 100,
                     name: 'test2')
        @pd1 = create(:project_dependency,
                      library_name: 'test',
                      project_from_id: @t2.id,
                      project_to_id: nil)
        LibraryRelation.new.perform(mode: 'diff')
      end

      it 'エラーリストに格納されること' do
        results = LibraryRelationError.all

        expect(results.count).to eq 1
        expect(results[0].library_name).to eq 'test'
      end
    end
  end

  describe 'プロジェクト完全/不完全チェック' do
    context 'プロジェクトが完全である場合' do
      before do
        @t1 = create(:project,
                     id: 10,
                     is_incomplete: true,
                     github_item_id: 99,
                     full_name: 'owner/parent_test',
                     name: 'parent_test',
                     export_status_id: 2)
        @pd1 = create(:project_dependency,
                      library_name: 'test',
                      project_from_id: @t1.id,
                      project_to_id: 999)
        LibraryRelation.new.perform
      end
      it 'プロジェクト不完全フラグが0(完全)となること' do
        expect(Project.find(@t1.id).is_incomplete).to eq false
      end

      it 'Web連携フラグが0(未連携)となること' do
        expect(Project.find(@t1.id).export_status_id).to eq 0
      end
    end

    context 'プロジェクトが不完全(github_item_idがない)である場合' do
      before do
        @t1 = create(:project,
                     id: 10,
                     is_incomplete: true,
                     github_item_id: nil,
                     full_name: 'owner/parent_test',
                     name: 'parent_test',
                     export_status_id: 2)
        @pd1 = create(:project_dependency,
                      library_name: 'test',
                      project_from_id: @t1.id,
                      project_to_id: 999)
        LibraryRelation.new.perform
      end

      it 'プロジェクト不完全フラグが1(不完全)であること' do
        expect(Project.find(@t1.id).is_incomplete).to eq true
      end

      it '不完全な場合はWeb側でも見えないのでexport_status_idは以前のまま(なんでも良い)' do
        expect(Project.find(@t1.id).export_status_id).to eq 2
      end
    end

    context 'プロジェクトが不完全(ライブラリ紐付けが完全でない)である場合' do
      before do
        @t1 = create(:project,
                     id: 10,
                     is_incomplete: true,
                     github_item_id: nil,
                     full_name: 'owner/parent_test',
                     name: 'parent_test')
        @pd1 = create(:project_dependency,
                      library_name: 'test',
                      project_from_id: @t1.id,
                      project_to_id: nil)
        LibraryRelation.new.perform
      end

      it 'プロジェクト不完全フラグが1(不完全)であること' do
        expect(Project.find(@t1.id).is_incomplete).to eq true
      end
    end

    context 'プロジェクト不完全フラグが0(完全)であるが情報としては不完全である場合' do
      before do
        @t1 = create(:project,
                     id: 10,
                     is_incomplete: false,
                     github_item_id: nil,
                     full_name: 'owner/parent_test',
                     name: 'parent_test')
        @pd1 = create(:project_dependency,
                      library_name: 'test',
                      project_from_id: @t1.id,
                      project_to_id: nil)
        LibraryRelation.new.perform
      end

      it '処理対象とならずプロジェクト不完全フラグは0(完全)であること' do
        expect(Project.find(@t1.id).is_incomplete).to eq false
      end
    end
  end

  describe 'プロジェクトタイプ判定' do
    context 'プロジェクトが完全である かつ 第1階層にgemspecがある場合' do
      before do
        @t1 = create(:project,
                     id: 10,
                     is_incomplete: true,
                     github_item_id: 99,
                     full_name: 'owner/parent_test',
                     name: 'parent_test')
        @pd1 = create(:project_dependency,
                      library_name: 'test',
                      project_from_id: @t1.id,
                      project_to_id: 999)
        create(:project_tree,
               path: 'parent_test.gemspec',
               project_id: @t1.id,
               file_type: 'blob')
        LibraryRelation.new.perform
      end
      it 'プロジェクトタイプが2(Rubygem)となること' do
        expect(Project.find(@t1.id).project_type_id).to eq 2
      end
    end

    context 'プロジェクトが完全である かつ 第2階層にgemspecがある場合' do
      before do
        @t1 = create(:project,
                     id: 10,
                     is_incomplete: true,
                     github_item_id: 99,
                     full_name: 'owner/parent_test',
                     name: 'parent_test')
        @pd1 = create(:project_dependency,
                      library_name: 'test',
                      project_from_id: @t1.id,
                      project_to_id: 999)
        create(:project_tree,
               path: 'test/parent_test.gemspec',
               project_id: @t1.id,
               file_type: 'blob')

        # 関係のないプロジェクト情報を含めた場合でもうまくいくことを確認する
        @t2 = create(:project,
                     id: 11,
                     is_incomplete: true,
                     github_item_id: 100,
                     full_name: 'owner/parent_test3',
                     name: 'parent_test')
        @pd1 = create(:project_dependency,
                      library_name: 'test3',
                      project_from_id: @t2.id,
                      project_to_id: 1000)
        create(:project_tree,
               path: 'parent_test3.gemspec',
               project_id: @t2.id,
               file_type: 'blob')

        LibraryRelation.new.perform
      end
      it 'プロジェクトタイプが1(Project)となること' do
        expect(Project.find(@t1.id).project_type_id).to eq 1
      end
    end

    context 'プロジェクトが完全である gemspecがない場合' do
      before do
        @t1 = create(:project,
                     id: 10,
                     is_incomplete: true,
                     github_item_id: 99,
                     full_name: 'owner/parent_test',
                     name: 'parent_test')
        @pd1 = create(:project_dependency,
                      library_name: 'test',
                      project_from_id: @t1.id,
                      project_to_id: 999)
        create(:project_tree,
               path: 'parent_test.gemspec2',
               project_id: @t1.id,
               file_type: 'blob')
        create(:project_tree,
               path: 'parent_test.gemspec',
               project_id: @t1.id,
               file_type: 'tree')

        # 関係のないプロジェクト情報を含めた場合でもうまくいくことを確認する
        @t2 = create(:project,
                     id: 11,
                     is_incomplete: true,
                     github_item_id: 100,
                     full_name: 'owner/parent_test3',
                     name: 'parent_test')
        @pd1 = create(:project_dependency,
                      library_name: 'test3',
                      project_from_id: @t2.id,
                      project_to_id: 1000)
        create(:project_tree,
               path: 'parent_test3.gemspec',
               project_id: @t2.id,
               file_type: 'blob')

        LibraryRelation.new.perform
      end

      it 'プロジェクトタイプが1(Project)となること' do
        expect(Project.find(@t1.id).project_type_id).to eq 1
      end
    end

    context 'プロジェクトが不完全(github_item_idがない)である場合' do
      before do
        @t1 = create(:project,
                     id: 10,
                     is_incomplete: true,
                     github_item_id: nil,
                     full_name: 'owner/parent_test',
                     name: 'parent_test',
                     project_type_id: 999)
        @pd1 = create(:project_dependency,
                      library_name: 'test',
                      project_from_id: @t1.id,
                      project_to_id: 999)
        LibraryRelation.new.perform
      end
      it 'プロジェクトタイプが変わらないこと' do
        expect(Project.find(@t1.id).project_type_id).to eq 999
      end
    end
  end
end
