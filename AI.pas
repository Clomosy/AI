var
  MyForm:TclForm;
  BtnSend:TclProButton;
  LblDisplay:TclLabel;
  MemMsg:TclMemo;
  ghMsgList,MsgList:TclMemo;
  MyOpenAIEngine:TclOpenAIEngine;
  bigPanel,smallPanel,middlePanel:TclProPanel;
  bigLyt:TClLayout;
  sendLbl:TClProLabel;
  MyMQTT : TclMQTT;
  GetTimer,
  settingsTmr: TClTimer;
  sayac:integer;
 

  Procedure BtnSendClick;
  begin
   if Clomosy.AppUserProfile=1 then 
   begin
      //MyOpenAIEngine.OnNewMessageEvent := 'OnNewMessageEvent';
      if MemMsg.Text = '' then
      begin
          ShowMessage('Write your question!');
      end
      else
      begin
          MyOpenAIEngine.SendAIMessage(MemMsg.Text);
          MemMsg.Text := '';
      end;
   end;
   
  End;
  Procedure OnNewMessageEvent;
  begin
  
      if MyMQTT.ReceivedAlright = False then
      begin
        MsgList.Lines.Add('');
        MyMQTT.Send(MyOpenAIEngine.NewMessageContent);
          if Clomosy.AppUserProfile = 1 then
            MsgList.Lines.Add(MyOpenAIEngine.NewMessageContent);
        MsgList.ScrollTo(0,MsgList.Lines.Count*MsgList.Lines.Count,True);
      end;
  End;
  
  Procedure MyMQTTStatusChanged;
  begin
    If MyMQTT.Connected Then 
    begin 
    //LblDisplay.Text := 'Connected' ;
      LblDisplay.TextSettings.FontColor := clAlphaColor.clHexToColor('#00ff00');
    end
    Else 
    begin
    //LblDisplay.Text := 'Not Connected';
      LblDisplay.TextSettings.FontColor := clAlphaColor.clHexToColor('#ff0000');
    end;
  End; 
  Procedure MyMQTTPublishReceived;
  begin
        If MyMQTT.ReceivedAlright Then 
        Begin
          if Clomosy.AppUserProfile <> 1 then
          begin
            MsgList.Lines.Add('');
            MsgList.Lines.Add('                   ' + MyMQTT.ReceivedMessage);
    	      MsgList.ScrollTo(0,MsgList.Lines.Count*MsgList.Lines.Count,True);
    	      if MyMQTT.ReceivedMessage = 'e95vX2faG@3M' then
            begin
              MsgList.Text := '';
              MsgList.Visible := False;
            end;
    	      if MyMQTT.ReceivedMessage = '52eJz#EzV6Yz' then
            begin
              MsgList.Text := '';
              MsgList.Visible := True;
            end;
          end;
        End;
  end;
  procedure runTimer;
  begin
    if sayac >= 0 then
       Dec(sayac);
       
    BtnSend.caption := IntToStr(sayac);
    if sayac = 19 then
    begin
      if Clomosy.AppUserProfile = 1 then
      begin
      MyMQTT.Send('e95vX2faG@3M');	
     
      end;
    end;
    if sayac =1 then
    begin
      if Clomosy.AppUserProfile = 1 then
      begin
        ShowMessage('Now you can start asking your questions.');
        MemMsg.Enabled := True;
        MemMsg.SetFocus;
        BtnSend.Enabled := True;
        BtnSend.caption := 'Send';
      end;
      MsgList.Visible := True;
      MsgList.Text := '';
      
      GetTimer.Enabled := False;
      sayac := 20;
      MyMQTT.Send('52eJz#EzV6Yz');	
      
    end;
  end;
  
begin
  MyForm := TclForm.Create(Self);
  MyForm.SetFormBGImage('https://clomosy.com/educa/bg5.png');
  
  
  bigLyt := MyForm.AddNewLayout(MyForm,'bigLyt');
  bigLyt.Align:=alContents;
  bigLyt.Margins.Left:=20;
  bigLyt.Margins.Right:=20;
  bigLyt.Margins.Top:=30;
  bigLyt.Margins.Bottom:=30;

  smallPanel:=MyForm.AddNewProPanel(bigLyt,'smallPanel');
  clComponent.SetupComponent(smallPanel,'{"Align" : "Top","Width" :300,"Height":50,"RoundHeight":10,
  "MarginBottom":10,"RoundWidth":10,"BorderColor":"#808080","BorderWidth":2,"BackgroundColor":"9b9b9b"}');


  LblDisplay:= MyForm.AddNewLabel(smallPanel,'LblDisplay','CLOMOSY AI');
  LblDisplay.Align := alcenter;
  LblDisplay.StyledSettings := ssFamily;
  LblDisplay.TextSettings.Font.Size := 18;
  LblDisplay.TextSettings.FontColor := clAlphaColor.clHexToColor('#000000');
  LblDisplay.Margins.Left:=10;
  LblDisplay.Margins.Right:=10;
  LblDisplay.Height:=45;
  LblDisplay.Width := 200;
  
  MyMQTT := MyForm.AddNewMQTTConnection(MyForm,'MyMQTT');
  MyForm.AddNewEvent(MyMQTT,tbeOnMQTTStatusChanged,'MyMQTTStatusChanged');
  MyForm.AddNewEvent(MyMQTT,tbeOnMQTTPublishReceived,'MyMQTTPublishReceived');
    
  //ShowMessage(Clomosy.Project_GUID);
  MyMQTT.Channel := 'chat';//project guid + channel
  MyMQTT.Connect;

  middlePanel:=MyForm.AddNewProPanel(bigLyt,'middlePanel');
  clComponent.SetupComponent(middlePanel,'{"Align" : "Top","MarginRight":10,"MarginLeft":10,"Width" :300,"Height":100,
  "RoundHeight":10,"RoundWidth":10,"BorderColor":"#008000","BorderWidth":3}');
  
   
  bigPanel:=MyForm.AddNewProPanel(bigLyt,'bigPanel');
  clComponent.SetupComponent(bigPanel,'{"Align" : "Client","MarginRight":10,"MarginLeft":10,
  "RoundHeight":10,"RoundWidth":10,"BorderColor":"#008000","BorderWidth":3}');
  
  MsgList:= MyForm.AddNewMemo(bigPanel,'MsgList','');
  MsgList.Align := alClient;
  MsgList.ReadOnly := True;
  MsgList.Margins.Top:= 10;
  MsgList.Margins.Left:= 10;
  MsgList.Margins.Right :=10;
  MsgList.TextSettings.Font.Size:=26;
  MsgList.TextSettings.WordWrap := True;
  MsgList.EnabledScroll := True;  
  MsgList.Visible := False;
  
    MemMsg:= MyForm.AddNewMemo(middlePanel,'MemMsg','');
    MemMsg.Align := alTop;
    MemMsg.Margins.Right:=10;
    MemMsg.Margins.Left:=10;
    MemMsg.Margins.Bottom:= 10;
    MemMsg.Enabled := False;
    
     BtnSend := MyForm.AddNewProButton(middlePanel,'BtnSend','');
     clComponent.SetupComponent(BtnSend,'{"caption":"Send","Align" : "Bottom",
    "MarginLeft":100,"MarginRight":100,"RoundHeight":2, "RoundWidth":2,"MarginBottom":8,
    "BorderColor":"#808080","BorderWidth":2,"TextBold":"yes"}');
     BtnSend.Enabled := False;
  
  
  if Clomosy.AppUserProfile = 1 then
  begin
      MyForm.AddNewEvent(BtnSend,tbeOnClick,'BtnSendClick');
      MyOpenAIEngine:=TclOpenAIEngine.Create(Self);
      MyOpenAIEngine.ParentForm := MyForm;
    //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
    //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
     
      MyOpenAIEngine.SetToken('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');
      MyOpenAIEngine.OnNewMessageEvent := 'OnNewMessageEvent'; 
      ShowMessage('Hello!Wait for me to get ready. After 20 seconds you can manage me the problem.');
      sayac := 20;
      BtnSend.Caption := IntToStr(sayac);
      GetTimer:= MyForm.AddNewTimer(MyForm,'GetTimer',1000);
      GetTimer.Enabled := True;
      MyForm.AddNewEvent(GetTimer,tbeOnTimer,'runTimer');
  end;
  
  
  
  MyForm.Run;
  
  
End;
