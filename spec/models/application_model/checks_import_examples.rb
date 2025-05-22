# Copyright (C) 2012-2025 Zammad Foundation, https://zammad-foundation.org/

RSpec.shared_examples 'ApplicationModel::ChecksImport' do
  describe '#id (for referential integrity during (e.g. OTRS/Zendesk/Freshdesk) import)' do
    subject { build(described_class.name.underscore, id: next_id + 1) }

    let(:next_id) do
      ActiveRecord::Base.connection.execute(<<~QUERY).first['last_value'].next
        SELECT last_value FROM #{described_class.table_name}_id_seq
      QUERY
    end

    context 'when Setting.get("system_init_done") is false (regardless of import_mode)' do
      before { Setting.set('system_init_done', false) }

      it 'allows explicit setting of #id attribute' do
        expect { subject.save! }.not_to change(subject, :id)
      end
    end

    context 'when Setting.get("system_init_done") is true' do
      before { Setting.set('system_init_done', true) }

      context 'and Setting.get("import_mode") is false' do
        before { Setting.set('import_mode', false) }

        it 'prevents explicit setting of #id attribute' do
          expect { subject.save! }.to change(subject, :id)
        end
      end

      context 'and Setting.get("import_mode") is true' do
        before { Setting.set('import_mode', true) }

        shared_examples 'importable classes' do
          it 'allows explicit setting of #id attribute' do
            expect { subject.save! }.not_to change(subject, :id)
          end
        end

        shared_examples 'non-importable classes' do
          it 'prevents explicit setting of #id attribute' do
            expect { subject.save! }.to change(subject, :id)
          end
        end

        include_examples described_class.importable? ? 'importable classes' : 'non-importable classes'
      end
    end
  end
end
