<?php
/**
 * Subset of Alfred workflow to extract 2FA codes from iMessage.
 * 
 * @author https://github.com/squatto
 * @link https://github.com/squatto/alfred-imessage-2fa
 */
 
/*
 * MIT License
 * 
 * Copyright (c) 2016 Till Krüss
 * 
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 * 
 * The above copyright notice and this permission notice shall be included in all
 * copies or substantial portions of the Software.
 * 
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
 * SOFTWARE.
 */

$dbPath = $_SERVER['HOME'] . '/Library/Messages/chat.db';

if ( !is_readable( $dbPath ) ) {
    exit( 'Grant Raycast "Full Drive Access" in privacy settings to access iMessages' );
}

$db = new PDO('sqlite:' . $dbPath);
$db->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);

$query = $db->query("
    select
        message.rowid,
        ifnull(handle.uncanonicalized_id, chat.chat_identifier) AS sender,
        message.service,
        datetime(message.date / 1000000000 + 978307200, 'unixepoch', 'localtime') AS message_date,
        message.text
    from
        message
            left join chat_message_join
                    on chat_message_join.message_id = message.ROWID
            left join chat
                    on chat.ROWID = chat_message_join.chat_id
            left join handle
                    on message.handle_id = handle.ROWID
    where
        is_from_me = 0
        and text is not null
        and length(text) > 0
        and (
            text glob '*[0-9][0-9][0-9][0-9][0-9]*'
            or text glob '*[0-9][0-9][0-9][0-9][0-9][0-9]*'
            or text glob '*[0-9][0-9][0-9][0-9][0-9][0-9][0-9]*'
            or text glob '*[0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9]*'
        )
    order by
        message.date desc
    limit 100
");

while ($message = $query->fetch(PDO::FETCH_ASSOC)) {
    if (preg_match('/(^|\s|\R|\t|G-|:)(\d{5,8})($|\s|\R|\t|\.)/', $message['text'], $matches)) {
        echo $matches[2] . ';' . $message['sender'] . ';' . $message['message_date'] . "\n";
        exit;
    }
}

echo 'No two factor authentication codes found';