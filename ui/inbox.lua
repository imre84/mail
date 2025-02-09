-- translation
local S = minetest.get_translator("mail")


function mail.show_inbox(name, sortfieldindex, sortdirection, filter)
    sortfieldindex = tonumber(sortfieldindex or mail.selected_idxs.sortfield[name]) or 3
    sortdirection = sortdirection or mail.selected_idxs.sortdirection[name] or "1"
    filter = filter or mail.selected_idxs.filter[name] or ""
    mail.selected_idxs.inbox[name] = mail.selected_idxs.inbox[name] or {}

    local inbox_formspec = "size[8.5,10;]" .. mail.theme .. [[
        tabheader[0.3,1;boxtab;]] .. S("Inbox") .. "," .. S("Sent messages").. "," .. S("Drafts") .. [[;1;false;false]

        button[6,0.10;2.5,0.5;new;]] .. S("New") .. [[]
        button[6,0.95;2.5,0.5;read;]] .. S("Read") .. [[]
        button[6,1.70;2.5,0.5;reply;]] .. S("Reply") .. [[]
        button[6,2.45;2.5,0.5;replyall;]] .. S("Reply all") .. [[]
        button[6,3.20;2.5,0.5;forward;]] .. S("Forward") .. [[]
        button[6,3.95;2.5,0.5;delete;]] .. S("Delete") .. [[]
        button[6,4.82;2.5,0.5;markread;]] .. S("Mark Read") .. [[]
        button[6,5.55;2.5,0.5;markunread;]] .. S("Mark Unread") .. [[]
        button[6,6.8;2.5,0.5;contacts;]] .. S("Contacts") .. [[]
        button[6,7.6;2.5,0.5;maillists;]] .. S("Mail lists") .. [[]
        button[6,8.7;2.5,0.5;about;]] .. S("About") .. [[]
        button_exit[6,9.5;2.5,0.5;quit;]] .. S("Close") .. [[]

        dropdown[0,8.4;2,0.5;sortfield;]] ..
        S("From") .. "," .. S("Subject") .. "," .. S("Date") .. [[;]] .. sortfieldindex .. [[;true]
        dropdown[2.0,8.4;2,0.5;sortdirection;]] ..
        S("Ascending") .. "," .. S("Descending") .. [[;]] .. sortdirection .. [[;true]
        field[4.25,8.85;1.4,0.5;filter;]] .. S("Filter") .. [[:;]] .. filter .. [[]
        button[5.14,8.52;0.85,0.5;search;Q]

        checkbox[0,9.1;multipleselection;]] .. S("Allow multiple selection") .. [[;]] ..
        tostring(mail.selected_idxs.multipleselection[name]) .. [[]
        label[0,9.65;]] .. tostring(#mail.selected_idxs.inbox[name]) .. " " .. S("selected") .. [[]
        button[3.5,9.5;2.5,0.5;selectall;]] .. S("(Un)select all") .. [[]

        tablecolumns[color;text;text]
        table[0,0.7;5.75,7.35;inbox;#999,]] .. S("From") .. "," .. S("Subject")
    local formspec = { inbox_formspec }
    local entry = mail.get_storage_entry(name)
    local sortfield = ({"from","subject","time"})[sortfieldindex]
    local messages = mail.sort_messages(entry.inbox, sortfield, sortdirection == "2", filter)

    mail.message_drafts[name] = nil

    if #messages > 0 then
        for _, message in ipairs(messages) do
            local selected_id = 0
            -- check if message is in selection list and return its id
            if mail.selected_idxs.inbox[name] and #mail.selected_idxs.inbox[name] > 0 then
                for i, selected_msg in ipairs(mail.selected_idxs.inbox[name]) do
                    if message.id == selected_msg then
                        selected_id = i
                        break
                    end
                end
            end
            if selected_id > 0 then
                if not message.read then
                    if not mail.player_in_list(name, message.to) then
                        formspec[#formspec + 1] = ",#A39E5D"
                    else
                        formspec[#formspec + 1] = ",#A39E19"
                    end
                else
                    if not mail.player_in_list(name, message.to) then
                        formspec[#formspec + 1] = ",#899888"
                    else
                        formspec[#formspec + 1] = ",#466432"
                    end
                end
            else
                if not message.read then
                    if not mail.player_in_list(name, message.to) then
                        formspec[#formspec + 1] = ",#FFD788"
                    else
                        formspec[#formspec + 1] = ",#FFD700"
                    end
                else
                    if not mail.player_in_list(name, message.to) then
                        formspec[#formspec + 1] = ",#CCCCDD"
                    else
                        formspec[#formspec + 1] = ","
                    end
                end
            end
            formspec[#formspec + 1] = ","
            formspec[#formspec + 1] = minetest.formspec_escape(message.from)
            formspec[#formspec + 1] = ","
            if message.subject ~= "" then
                if string.len(message.subject) > 30 then
                    formspec[#formspec + 1] = minetest.formspec_escape(string.sub(message.subject, 1, 27))
                    formspec[#formspec + 1] = "..."
                else
                    formspec[#formspec + 1] = minetest.formspec_escape(message.subject)
                end
            else
                formspec[#formspec + 1] = S("(No subject)")
            end
        end
        formspec[#formspec + 1] = "]"
    else
        formspec[#formspec + 1] = "]label[2.25,4.5;" .. S("No mail") .. "]"
    end
    minetest.show_formspec(name, "mail:inbox", table.concat(formspec, ""))
end
