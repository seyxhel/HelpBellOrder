# Copyright (C) 2012-2025 Zammad Foundation, https://zammad-foundation.org/

require 'rails_helper'
require 'system/examples/pagination_examples'

RSpec.describe 'AI > AI Agents', type: :system do
  context 'when ajax pagination' do
    include_examples 'pagination', model: :ai_agent, klass: AI::Agent, path: 'ai/ai_agents'
  end

  context 'when no AI provider is configured' do
    it 'shows a warning message' do
      visit '#ai/ai_agents'

      expect(page).to have_text('The provider configuration is missing. Please set up the provider before proceeding in AI > Provider.')
    end
  end

  context 'when AI provider is configured', required_envs: %w[OPEN_AI_TOKEN] do
    before do
      Setting.set('ai_provider', 'open_ai')
      Setting.set('ai_provider_config', {
                    token: ENV['OPEN_AI_TOKEN'],
                  })
    end

    context 'with existing AI agent(s)' do
      let(:ai_agent) { create(:ai_agent, name: 'Test Agent', agent_type: 'TicketGroupDispatcher') }
      let(:trigger)  { create(:trigger, perform: { 'ai.ai_agent' => { 'ai_agent_id' => ai_agent.id } }) }
      let(:job)      { create(:job, perform: { 'ai.ai_agent' => { 'ai_agent_id' => ai_agent.id } }) }

      before do
        trigger && job
      end

      it 'shows AI agent in the UI' do
        visit '#ai/ai_agents'

        within :active_content do
          expect(page).to have_text(ai_agent.name)
            .and have_text(trigger.name)
            .and have_text(job.name)
        end
      end

      context 'with references' do

        # AI agent #1: one job, multiple triggers
        let(:ai_agent_1) { create(:ai_agent, name: 'AI Agent 1') }

        # AI agent #2: multiple job, one trigger
        let(:ai_agent_2) { create(:ai_agent, name: 'AI Agent 2') }

        # AI agent #3: no references
        let(:ai_agent_3) { create(:ai_agent, name: 'AI Agent 3') }

        before do
          create(:trigger, name: 'Trigger1 Group Dispatcher 1', perform: { 'ai.ai_agent' => { 'ai_agent_id' => ai_agent_1.id } })
          create(:trigger, name: 'Trigger1 Group Dispatcher 2', perform: { 'ai.ai_agent' => { 'ai_agent_id' => ai_agent_1.id } })
          create(:job,     name: 'Job1 Group Dispatcher 1',     perform: { 'ai.ai_agent' => { 'ai_agent_id' => ai_agent_1.id } })

          create(:trigger, name: 'Trigger2 Group Dispatcher 1', perform: { 'ai.ai_agent' => { 'ai_agent_id' => ai_agent_2.id } })
          create(:job,     name: 'Job2 Group Dispatcher 1',     perform: { 'ai.ai_agent' => { 'ai_agent_id' => ai_agent_2.id } })
          create(:job,     name: 'Job2 Group Dispatcher 2',     perform: { 'ai.ai_agent' => { 'ai_agent_id' => ai_agent_2.id } })

          ai_agent_3
        end

        it 'shows AI agent with correct references' do
          visit '#ai/ai_agents'

          within ".js-tableBody tr.item[data-id='#{ai_agent_1.id}']" do
            expect(page).to have_text('AI Agent 1')
            expect(page).to have_text('2 triggers')
            expect(page).to have_text('Job1 Group Dispatcher 1')
          end

          within ".js-tableBody tr.item[data-id='#{ai_agent_2.id}']" do
            expect(page).to have_text('AI Agent 2')
            expect(page).to have_text('Trigger2 Group Dispatcher 1')
            expect(page).to have_text('2 schedulers')
          end

          within ".js-tableBody tr.item[data-id='#{ai_agent_3.id}']" do
            expect(page).to have_text('AI Agent 3')
            expect(page).to have_text('Unused')

            # Test that badge is removed when references are added.
            create(:trigger, name: 'Trigger3 Group Dispatcher 1', perform: { 'ai.ai_agent' => { 'ai_agent_id' => ai_agent_3.id } })
            await_empty_ajax_queue
            expect(page).to have_text('Trigger3 Group Dispatcher 1')
            expect(page).to have_no_text('Unused')

            # Test that references text is updated when references are changed.
            Job.last.update!(perform: { 'ai.ai_agent' => { 'ai_agent_id' => ai_agent_3.id } })
            await_empty_ajax_queue
            expect(page).to have_text('Job2 Group Dispatcher 2')

            # Test that references are removed/badge is added when the last reference is deleted.
            Trigger.last.destroy!
            Job.last.destroy!
            await_empty_ajax_queue
            expect(page).to have_no_text('Trigger3 Group Dispatcher 1')
            expect(page).to have_text('Unused')
          end
        end
      end

      context 'when editing an existing AI agent' do
        it 'guides the user through the wizard' do
          visit '#ai/ai_agents'

          click "tr[data-id='#{ai_agent.id}']"

          in_modal do
            expect(page).to have_text('Edit: AI Agent')

            check_input_field_value('name', ai_agent.name)
            fill_in 'name', with: 'Test Agent (edit)'
            check_select_field_value('agent_type', 'TicketGroupDispatcher')
            expect(page).to have_text('This type of AI agent can dispatch incoming tickets into an appropriate group based on their content and topic.')

            click_on 'Next'
            click 'label', text: 'LIMIT GROUPS'
            click_on 'Next'

            expect(page).to have_text('NOTE')
            expect(page).to have_text('ACTIVE')

            # Check navigation to the previous steps.
            click_on 'Back'
            click_on 'Back'

            check_input_field_value('name', 'Test Agent (edit)')
            check_select_field_value('agent_type', 'TicketGroupDispatcher')

            click_on 'Next'
            click_on 'Next'

            expect(page).to have_no_text('For this agent to run, it needs to be used in a trigger or a scheduler.')

            set_select_field_label('active', 'inactive')

            expect(page).to have_no_text('For this agent to run, it needs to be used in a trigger or a scheduler.')

            click_on 'Submit'
          end

          expect(page).to have_text('Test Agent (edit)')

          expect(ai_agent.reload).to have_attributes(
            name:   'Test Agent (edit)',
            active: false,
          )
        end
      end
    end

    context 'when creating a new AI agent', authenticated_as: :admin do
      let(:groups) { create_list(:group, 3) }
      let(:admin)  { create(:admin, groups: groups) }

      it 'guides the user through the wizard' do
        visit '#ai/ai_agents'

        click_on 'New AI Agent'

        in_modal do
          expect(page).to have_text('New: AI Agent')

          fill_in 'name', with: 'Test Agent'
          set_select_field_label('agent_type', 'Ticket Group Dispatcher')

          click_on 'Next'

          # Check frontend validation of the object attribute options context field.
          click_on 'Back'

          error_message = page.find('[name="definition::instruction_context::object_attributes::group_id-required-validator"]', visible: :all)
            .native
            .attribute('validationMessage')

          expect(error_message).to include('Please fill')

          click 'label', text: 'LIMIT GROUPS'

          # Check navigation to the previous step.
          click_on 'Back'

          check_input_field_value('name', 'Test Agent')
          check_select_field_value('agent_type', 'TicketGroupDispatcher')

          click_on 'Next'

          click 'label', text: 'LIMIT GROUPS'

          expect(page).to have_text('AVAILABLE GROUPS')

          tree_select_field = page.find(%( .searchableSelect-shadow+.js-input )) # search input
            .click                                                               # focus
            .ancestor('.controls', order: :reverse, match: :first)               # find container

          tree_select_field.find("[data-display-name='#{groups.first.name}']")
            .click

          find('.js-add').click

          tree_select_field = page.find(%( .searchableSelect-shadow+.js-input )) # search input
            .click                                                               # focus
            .ancestor('.controls', order: :reverse, match: :first)               # find container

          tree_select_field.find("[data-display-name='#{groups.second.name}']")
            .click

          find('.js-add').click

          click_on 'Next'

          expect(page).to have_text('For this agent to run, it needs to be used in a trigger or a scheduler.')

          set_select_field_label('active', 'inactive')

          expect(page).to have_no_text('For this agent to run, it needs to be used in a trigger or a scheduler.')

          set_select_field_label('active', 'active')

          expect(page).to have_text('For this agent to run, it needs to be used in a trigger or a scheduler.')

          click_on 'Submit'
        end

        expect(page).to have_text('Test Agent')

        expect(AI::Agent.last).to have_attributes(
          name:       'Test Agent',
          agent_type: 'TicketGroupDispatcher',
          definition: {
            'instruction_context' => {
              'object_attributes' => {
                'group_id' => {
                  groups.first.id.to_s  => '',
                  groups.second.id.to_s => '',
                },
              },
            },
          },
          active:     true,
        )
      end
    end
  end
end
