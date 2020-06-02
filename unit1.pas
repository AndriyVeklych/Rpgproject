unit Unit1;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, Menus, Buttons,
  ComCtrls, ExtCtrls, StdCtrls, Grids, DBGrids, DBCtrls, RichMemo,
  sqlite3conn, sqldb, db, Sqlite3DS, Math, Crt;

type

  { TForm1 }

  TForm1 = class(TForm)
    Button1: TButton;
    Button2: TButton;
    Button3: TButton;
    CheckBox1: TCheckBox;
    DataSource1: TDataSource;
    GroupBox1: TGroupBox;
    GroupBox2: TGroupBox;
    MainMenu1: TMainMenu;
    MenuItem1: TMenuItem;
    MenuItem10: TMenuItem;
    MenuItem11: TMenuItem;
    MenuItem2: TMenuItem;
    MenuItem3: TMenuItem;
    MenuItem4: TMenuItem;
    MenuItem5: TMenuItem;
    MenuItem6: TMenuItem;
    MenuItem7: TMenuItem;
    MenuItem8: TMenuItem;
    MenuItem9: TMenuItem;
    Panel1: TPanel;
    PopupMenu1: TPopupMenu;
    RichMemo1: TRichMemo;
    SQLite3Connection1: TSQLite3Connection;
    Sqlite3Dataset1: TSqlite3Dataset;
    SQLQuery1: TSQLQuery;
    SQLTransaction1: TSQLTransaction;
    StringGrid1: TStringGrid;
    StringGrid2: TStringGrid;
    StringGrid3: TStringGrid;
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure Button3Click(Sender: TObject);
    procedure FormClose(Sender: TObject; var CloseAction: TCloseAction);
    procedure FormCreate(Sender: TObject);
    procedure MenuItem10Click(Sender: TObject);
    procedure MenuItem11Click(Sender: TObject);
    procedure MenuItem2Click(Sender: TObject);
    procedure MenuItem3Click(Sender: TObject);
    procedure MenuItem4Click(Sender: TObject);
    //MyCostumProcedures
    procedure LocationFill();
    procedure MenuItem5Click(Sender: TObject);
    procedure MenuItem6Click(Sender: TObject);
    procedure MenuItem7Click(Sender: TObject);
    procedure MenuItem8Click(Sender: TObject);
    procedure MenuItem9Click(Sender: TObject);
    procedure MobsOnLocation();

    procedure StringGrid1MouseUp(Sender: TObject; Button: TMouseButton;
       Shift: TShiftState; Y: Integer);
    procedure StringGrid2MouseUp(Sender: TObject; Button: TMouseButton;
       Shift: TShiftState; Y: Integer);
    procedure AddColorStr(s: string; const col: TColor = clBlack;
       const NewLine: boolean = true);
       procedure InventorySort();
       procedure InterfaceState(State:integer);
       procedure LoadData();
       procedure PlayerStatsLoad();
       procedure LocationChange();
       procedure Battle(MobID:Integer);
       procedure RPGSQLLoadData();
       procedure RPGSQLConnection();
       procedure StatReload();
       procedure EXP_GAIN(EXP_amount:integer);
       procedure RPGSQLLoadPlayerData(PlayerLoadID:integer);
       procedure PlayerSave(SaveID:integer);
       procedure ResetPlayerStats();
       procedure StatPointsButtonsActive();
       procedure StringGrid3MouseUp(Sender: TObject; Button: TMouseButton;
         Shift: TShiftState; X, Y: Integer);
       procedure ZeroStatPoints();
       procedure PlayerInfo();
       procedure StatMod();
       procedure PickItem(ItemID:integer);
       procedure DropItem(ItemID:integer);
       procedure DropItemSlot(InventorySlot:integer; FullSlot:boolean);
       procedure EquipOrUseItem(ItemID:integer);
       procedure UnequipItem(ItemID:integer);
       procedure ItemsToArrays();
       procedure ArraysToItems();
       procedure DropListArray();
       procedure InventoryFill();
       procedure QuestProgressCheck(QuestID:integer);
       procedure SortQuests();
       procedure RequirementsLoad(QuestID:integer);
       procedure RewardsLoad(QuestID:integer);
       procedure TakeQuest(QuestID:integer);
       procedure QuestProgressToArrays();
       procedure QuestProgressSave();
       function LevelFormula   : integer;
       function CritFormula    : integer;
       function DodgeFormula   : integer;
       function BlockFormula   : integer;
       function DiceRoll(dices, faces :integer) :integer;
       function ItemDescription(ItemID:Integer):String;

        //EndOfMyBullshit


  private

  public

  end;
 const
// Значения размеров массивов в константах
   MaxLocations = 100;
   MaxLocationsOnPage = 10;
   DMGReductionArmor = 5;
   ItemParamsCount = 16;
   MaxPlayerParams = 14;
   MobsParamsCount = 11;
//   DMGReductionBlock = 2;
   MaxMobs = 99;
   StatPointPerLevel = 1;
   EquipmentCount = 3;
      MaxInventory = 50;
      MaxStack = 20;
      MaxDrops = 10;
      MaxQuests = 50;
      MaxActiveQuests = 3;
var
  Form1: TForm1;

  ////////////////Переменные характеристик игрока
  player_EXP, player_LEVEL, player_statpoint, player_Coins,
    player_OFFENCE, player_DEFENCE, player_OBSERVATION,
    MP_OFFENCE, MP_DEFENCE, MP_OBSERVATION, ItemsInInventory,
  player_HP, player_AHP, player_DMG, player_ARMOR, player_DODGE, player_BLOCK,
    player_BLOCKDMG, player_CritChance, player_CritDMG:   Integer;
 player_NAME, player_ItemStack, player_Inventory, player_Equipment,
   player_QuestProgress: String;

 //Модификаторы характеристик
   SMP_HP, SMP_DMG, SMP_ARMOR, SMP_DODGE, SMP_BLOCK, SMP_BLOCKDMG, SMP_CritChance,
     SMP_CritDMG, SMP_OFFENCE, SMP_DEFENCE, SMP_OBSERVATION:   Integer;
 //характеристики врага подгружать из файла xml
  enemy_NAME, DroplistString: String;
  enemy_HP, enemy_DMG, enemy_ARMOR, enemy_DODGE, enemy_BLOCK, enemy_BLOCKDMG, enemy_CritChance,
  enemy_EXP,   enemy_CritDMG:   Integer;

  //Настройки прогаммы
  NoMoreLines: Integer;
  // Переменные массивов локаций
  CurrentLocation: Integer;        // номер текущей локации
  // Переменные размеров массивов
  NowMobCount, LAL, NowLocCount: Integer;
  // Значения размеров массивов в константах
  Items:              array [1..ItemParamsCount, 1..100] of String;  //Массив айтемов
  AMobs:              array [1..MaxMobs,1..MobsParamsCount] of String; //Массив мобов и их характеристик
  LocAccNow:          array [1..MaxLocationsOnPage] of String; //Временный массив
  LocAccess:          array [1..MaxLocations] of String; //  Массив доступных локаций из текущей локации
  LocNames:           array [1..MaxLocations] of String;       //Массив названий локаций
  LocMobs:            array [1..MaxLocations] of String;  //массив доступных мобов из даной локи
  MobsOnLoc:          array [1..10] of String;
  PlayerStat:         array [1..MaxPlayerParams] of String;
  Equipment:          array [1..EquipmentCount] of String;
  Inventory:          array [1..MaxInventory] of String;
  ItemStack:          array [1..MaxInventory] of String;
  DropList:           array [1..MaxMobs, 1..MaxDrops] of String;
  Quest:              array [1..MaxQuests, 1..9] of String;
  QuestRequirements:  array [1..4] of String;
  QuestRewards:       array [1..3] of String;
  QuestProgress:      array [1..MaxActiveQuests, 1..2] of Integer;
  TestArray: array[1..1] of integer;

implementation

{$R *.lfm}

{ TForm1 }

//
procedure TForm1.EquipOrUseItem(ItemID:integer);
var i,TypeID:Integer; tempstr:String;
begin
TypeID:=StrToInt(Items[2,ItemID]);
if (TypeID=1) or (TypeID=2) or (TypeID=3) then
begin
  for i:=1 to MaxInventory do
  begin
  if Inventory[i]=IntToStr(ItemID) then
    begin
      tempstr:=Equipment[TypeID];
      Equipment[TypeID]:=IntToStr(ItemID);
      Inventory[i]:=tempstr;
      InventoryFill();
      break;
    end;
  end;
end;

end;

//
procedure TForm1.UnequipItem(ItemID:integer);
begin

end;

//Процедура в которой будут вариации состояния интерфейса
procedure TForm1.InterfaceState(State:integer);
begin
  case State of
    0: begin        //Обычное окно локации+монстры, убрать инвентарь
      Panel1.show;
      GroupBox2.hide;
    end;
    1: begin        //Онкно инвентаря, убрать локации-монстры
      Panel1.hide;
      GroupBox2.show;
    end;
    2: begin
    end;
  end;
end;

//Загрузка строковых перечислений предметов и экипировки в массивы предметов и экипировки
procedure TForm1.ItemsToArrays();
var i,j:Integer;
begin

for j:=1 to EquipmentCount do
  begin
    Equipment[j]:='';
  end;

i:=1;
for j:=1 to Length(player_Equipment) do
  begin
  if not(player_Equipment[j]=' ') then
    Equipment[i]:=Equipment[i]+player_Equipment[j]
  else
    i:=i+1;
  end;

for j:=1 to MaxInventory do
  begin
    Inventory[j]:='';
    ItemStack[j]:='';
  end;

i:=1;
for j:=1 to Length(player_Inventory) do
  begin
  if not(player_Inventory[j]=' ') then
    Inventory[i]:=Inventory[i]+player_Inventory[j]
  else
    i:=i+1;
  end;

i:=1;
for j:=1 to Length(player_ItemStack) do
  begin
  if not(player_ItemStack[j]=' ') then
    ItemStack[i]:=ItemStack[i]+player_ItemStack[j]
  else
    i:=i+1;
  end;

end;

procedure TForm1.ArraysToItems();
var i:integer;
begin
player_Equipment:='';
player_Inventory:='';
player_ItemStack:='';
for i:=1 to EquipmentCount do
  begin
  if Equipment[i]='' then
    Equipment[i]:=IntToStr(i+1);
  if not(i=EquipmentCount) then
     player_Equipment:=player_Equipment+Equipment[i]+' '
  else
  player_Equipment:=player_Equipment+Equipment[i];
  end;
  InventorySort();
  for i:=1 to MaxInventory do
  begin
    if not(Inventory[i]='') and not(i=MaxInventory) then
      player_Inventory:=player_Inventory+Inventory[i]+' '
    else
      player_Inventory:=player_Inventory+Inventory[i];
  end;

  for i:=1 to MaxInventory do
  begin
    if not(ItemStack[i]='') and not(i=MaxInventory) then
      player_ItemStack:=player_ItemStack+ItemStack[i]+' '
    else
      player_ItemStack:=player_ItemStack+ItemStack[i];
  end;
{if player_Inventory='' then       //это шмотки которые будут восстанавливатся
  player_Inventory:='1';}          //при полностью пустом инвентаре
end;

//Сортировка инвентаря
procedure TForm1.InventorySort();
var i,j:integer;
begin
  ItemsInInventory:=MaxInventory;
  for i:=1 to MaxInventory do
  begin
    if (Inventory[i]='')or(ItemStack[i]='0') then
    begin
      ItemsInInventory:=ItemsInInventory-1;
      for j:=i to MaxInventory-1 do
      begin
        Inventory[j]:=Inventory[j+1];
        ItemStack[j]:=ItemStack[j+1];
      end;
      Inventory[MaxInventory]:='';
      ItemStack[MaxInventory]:='';
    end;
  end;
end;


//поднять предмет
procedure TForm1.PickItem(ItemID:integer);
var i:integer; done:boolean;
begin
  done:=false;
  for i:=1 to MaxInventory do
  begin
    if (Inventory[i]=IntToStr(ItemID)) then
    begin
      if StrToInt(ItemStack[i])<20 then
      begin
        ItemStack[i]:=IntToStr(StrToInt(ItemStack[i])+1);
        done:=true;
        RichMemo1.Lines.Add('Вы подняли '+Items[1,ItemID]+' и поместили в свой инвентарь.');
        break;
      end;
    end;
  end;
  if done=false then
  begin
    for i:=1 to MaxInventory do
    begin
      if Inventory[i]='' then
      begin
        Inventory[i]:=IntToStr(ItemID);
        ItemStack[i]:='1';
        RichMemo1.Lines.Add('Вы подняли '+Items[1,ItemID]+' и поместили в свой инвентарь.');
        break;
      end
      else
        if i=MaxInventory then
      RichMemo1.Lines.Add('Места в инвентаре для данного предмета нет.');
    end;
  end;
  InventoryFill();
end;

//itemdroptoarray.
procedure TForm1.DropListArray();
var i,j,d:integer;
begin
  for i:=1 to MaxMobs do
  begin
    d:=1;
    for j:=1 to Length(AMobs[i,11]) do
    begin
      if not(AMobs[i,11][j]=' ') then
        DropList[i,d]:=DropList[i,d]+AMobs[i,11][j]
      else
        d:=d+1;
    end;
  end;
end;

//Берём Quest
procedure TForm1.TakeQuest(QuestID:integer);
var i:integer;
begin
  for i:=1 to MaxActiveQuests do
  begin
    if QuestProgress[i,1]=QuestID then
    begin
      ShowMessage('Это задание уже выполняется Вами!');
      break;
    end;
    if QuestProgress[i,1]=0 then
    begin
      QuestProgress[i,1]:=QuestID;
      QuestProgress[i,2]:=0;
      break;
    end;
    if i=MaxActiveQuests then
    ShowMessage('Взято максимальное колличество заданий!');
  end;
end;

//QuestProgressFill
procedure TForm1.QuestProgressToArrays();
var  i,j,k:integer;   number:string;
begin
  j:=1;
  k:=1;
  number:='';
  for i:=1 to Length(player_QuestProgress) do
  begin
    if not(player_QuestProgress[i]=' ') and not(player_QuestProgress[i]=';') then
      number:=number+player_QuestProgress[i];
    if player_QuestProgress[i]=' ' then
    begin
      QuestProgress[k,j]:=StrToInt(number);
      number:='';
      j:=j+1;
    end;
    if player_QuestProgress[i]=';' then
    begin
      QuestProgress[k,j]:=StrToInt(number);
      j:=1;
      k:=k+1;
      number:='';
    end;
  end;
end;

//сортировка заданий
procedure TForm1.SortQuests();
var i,j:integer;
begin
  for i:=1 to MaxActiveQuests do
  begin
    if QuestProgress[i,1]=0 then
    begin
      for j:=i to MaxActiveQuests-1 do
        QuestProgress[j,1]:=QuestProgress[j+1,1];
      QuestProgress[MaxActiveQuests,1]:=0;
      QuestProgress[MaxActiveQuests,2]:=0;
    end;
  end;
end;

//Сохранение прогресса в переменную которую пихаем в скуель
procedure TForm1.QuestProgressSave();
var i:integer;
begin
player_QuestProgress:='';
for i:=1 to MaxActiveQuests do
begin
if not(QuestProgress[i,1]=0) then
player_QuestProgress:=player_QuestProgress+IntToStr(QuestProgress[i,1])+' '+IntToStr(QuestProgress[i,2])+';';
end;
end;

//Журнал заданий
procedure TForm1.MenuItem11Click(Sender: TObject);
var i:integer;
begin
  SortQuests();
  if not(QuestProgress[1,1]=0) then
  begin
    RichMemo1.Lines.Add('В данный момент активны следующие задания:');
    for i:=1 to MaxActiveQuests do
    begin
      if not(QuestProgress[i,1]=0) then
      begin
        RichMemo1.Lines.Add(IntToStr(i)+'. '+Quest[QuestProgress[i,1],1]);
//        RichMemo1.Lines.Add(Quest[QuestProgress[i,1],2]);
        RichMemo1.Lines.AddStrings(Quest[QuestProgress[i,1],2]);
      end;
    end;
  end
  else
  RichMemo1.Lines.Add('В данный момент активных заданий нет.');
end;

//  QuestRequirements
procedure TForm1.RequirementsLoad(QuestID:integer);
var i,d:integer;
begin
d:=1;
  for i:=1 to Length(Quest[QuestID,d+2]) do
  begin
  if not(Quest[QuestID,d+2][i]=' ') and not(Quest[QuestID,d+2][i]='-') then
    QuestRequirements[d]:=QuestRequirements[d]+Quest[QuestID,d+2][i];
  if (Quest[QuestID,d+2][i]=' ') or (Quest[QuestID,d+2][i]='-') then
    d:=d+1;
  end;
end;


// QuestRewards
procedure TForm1.RewardsLoad(QuestID:integer);
var i,d:integer;
begin
d:=1;
  for i:=1 to Length(Quest[QuestID,d+6]) do
  begin
  if not(Quest[QuestID,d+6][i]=' ') and not(Quest[QuestID,d+6][i]='-') then
    QuestRewards[d]:=QuestRewards[d]+Quest[QuestID,d+6][i];
  if (Quest[QuestID,d+6][i]=' ') or (Quest[QuestID,d+6][i]='-') then
    d:=d+1;
  end;
end;

//проверяем завершили ли квест, если да, убираем его из активных и награждаем
procedure TForm1.QuestProgressCheck(QuestID:integer);
var SQ,i:integer; DoneKills, DoneItems :Boolean; s,t:string;
begin
  RequirementsLoad(QuestID);
  RewardsLoad(QuestID);
  s:='';
  DoneKills:=false;
  DoneItems:=false;
  if not(QuestRequirements[2]='') then
    begin
      if (QuestProgress[1,1]>=StrToInt(QuestRequirements[2])) then
      begin
        DoneKills:=True;
      end
      else
        s:='Цель '+AMobs[StrToInt(QuestRequirements[1]),1]+' (' +IntToStr(QuestProgress[1,1])+'/'+QuestRequirements[2]+').';
    end
  else
    DoneKills:=True;

  t:='';
  if not(QuestRequirements[4]='') then
  begin
    for i:=1 to MaxInventory do
    begin
      if (Inventory[i]=QuestRequirements[3]) and (StrToInt(ItemStack[i])>=StrToInt(QuestRequirements[4]))then
      begin
        DoneItems:=True;
      end;
    end;
    if not(DoneItems) then
    t:='Нужно собрать '+QuestRequirements[4]+' '+Items[1,StrToInt(QuestRequirements[3])]+'.';
  end
  else
  DoneItems:=True;

  for i:=1 to MaxActiveQuests do
  begin
    if QuestProgress[i,1]=QuestID then
      SQ:=i;
  end;
  if DoneItems and DoneItems then
  begin
    for i:=1 to StrToInt(QuestRequirements[4]) do
      DropItem(StrToInt(QuestRequirements[3]));
    QuestProgress[SQ,1]:=0;                                   //Очищаем текущий квестецкий
    QuestProgress[SQ,2]:=0;                                   //Очищаем текущий квестецкий
    EXP_GAIN(StrToInt(QuestRewards[1]));                      //Получаем опыт за квест
    player_Coins:=player_Coins+StrToInt(QuestRewards[2]);     //награда денюжками
    PickItem(StrToInt(QuestRewards[3]));                      //Награда шмоткой
  end;
  if DoneKills=false then
    RichMemo1.Lines.Add(s);
  if DoneItems=false then
    RichMemo1.Lines.Add(t);
  SortQuests();
end;

//Выкинуть предмет из СЛОТА инвентаря
procedure TForm1.DropItemSlot(InventorySlot:integer;FullSlot:boolean);
begin
  if not(FullSlot) then
  begin
    if StrToInt(ItemStack[InventorySlot])>1 then
    begin
      RichMemo1.Lines.Add('Предмет '+Items[1,StrToInt(Inventory[InventorySlot])]+' успешно выброшен из инвентаря.');
      ItemStack[InventorySlot]:=IntToStr(StrToInt(ItemStack[InventorySlot])-1)
    end
    else
    begin
      RichMemo1.Lines.Add('Предмет '+Items[1,StrToInt(Inventory[InventorySlot])]+' успешно выброшен из инвентаря.');
      Inventory[InventorySlot]:='';
      ItemStack[InventorySlot]:='';
      InventorySort();
    end;
  end
  else
  begin
    RichMemo1.Lines.Add('Связка предметов '+Items[1,StrToInt(Inventory[InventorySlot])]+' успешно выброшена из инвентаря.');
    Inventory[InventorySlot]:='';
    ItemStack[InventorySlot]:='';
    InventorySort();
  end;
end;

//Выкинуть предмет
procedure TForm1.DropItem(ItemID:integer);
var i:integer;
begin
for i:=1 to MaxInventory do
  begin
  if Inventory[i]=IntToStr(ItemID) then
  begin
    if StrToInt(ItemStack[i])>1 then
    ItemStack[i]:=IntToStr(StrToInt(ItemStack[i])-1)
    else
    begin
  Inventory[i]:='';
  ItemStack[i]:='';
  InventorySort();
  end;
  RichMemo1.Lines.Add('Предмет '+Items[1,ItemID]+' успешно выброшен из инвентаря.');
    break;
  end;
  end;
end;


function TForm1.ItemDescription(ItemID:Integer):String;
var tempstr:string;// i:integer;
begin
tempstr:='';
{case Items[2,ItemID] of.....// type
tempstr:=;
case Items[3,ItemID] of      //effect
tempstr:=tempstr+;   }
if not(Items[4,ItemID]='0') then
tempstr:=tempstr+' '+Items[4,ItemID]+' к нападению,';
if not(Items[5,ItemID]='0') then
tempstr:=tempstr+' '+Items[5,ItemID]+' к защите,';
if not(Items[6,ItemID]='0') then
tempstr:=tempstr+' '+Items[6,ItemID]+' к наблюдению,';
if not(Items[7,ItemID]='0') then
tempstr:=tempstr+' '+Items[7,ItemID]+' к здоровью,';
if not(Items[8,ItemID]='0') then
tempstr:=tempstr+' '+Items[8,ItemID]+' к урону,';
if not(Items[9,ItemID]='0') then
tempstr:=tempstr+' '+Items[9,ItemID]+' к броне,';
if not(Items[10,ItemID]='0') then
tempstr:=tempstr+' '+Items[10,ItemID]+'% к увороту,';
if not(Items[11,ItemID]='0') then
tempstr:=tempstr+' '+Items[11,ItemID]+'% к шансу блока,';
if not(Items[12,ItemID]='0') then
tempstr:=tempstr+' '+Items[12,ItemID]+' к блоку,';
if not(Items[13,ItemID]='0') then
tempstr:=tempstr+' '+Items[13,ItemID]+'% к шансу крита,';
if not(Items[14,ItemID]='0') then
tempstr:=tempstr+' '+Items[14,ItemID]+'% к крит. урону.';
if not(Items[15,ItemID]='0') then
tempstr:=tempstr+' Цена: '+Items[15,ItemID]+'.';

  Result:=tempstr;
end;

//драка с выводом в РИЧмемо1
procedure TForm1.Battle(MobID:integer);
var
attacker, target: String;
 nRand, target_HP, i, j, d, dropchance, enemy_AHP, target_AHP, attacker_DMG, target_ARMOR,
 target_DODGE, target_BLOCK, target_BLOCKDMG,
   attacker_CritChance, attacker_CritDMG:   Integer;     //Рассчётные к которым приравниваются игрока/врага;
  ICrit, IDodge, IBlock: Boolean; //Инстансы крита уворота и блока
begin
  //Подгрузка параметров моба.
  enemy_NAME:=AMobs[MobID,1];
  enemy_HP:=StrToInt(AMobs[MobID,2]);
  enemy_AHP:=enemy_HP;
  enemy_DMG:=StrToInt(AMobs[MobID,3]);
  enemy_ARMOR:=StrToInt(AMobs[MobID,4]);
  enemy_DODGE:=StrToInt(AMobs[MobID,5]);
  enemy_BLOCK:=StrToInt(AMobs[MobID,6]);
  enemy_BLOCKDMG:=StrToInt(AMobs[MobID,7]);
  enemy_CritChance:=StrToInt(AMobs[MobID,8]);
  enemy_CritDMG:=StrToInt(AMobs[MobID,9]);
  enemy_EXP:=StrToInt(AMobs[MobID,10]);
  RichMemo1.Lines.Add(player_NAME+' vs '+enemy_NAME);
  for i:=1 to 51 do
  begin
    Sleep(250);
    ICrit:=false;
    IBlock:=false;
    IDodge:=false;
    if odd(i) then   //не чёт  1/3/5
    begin
      target:=enemy_NAME;
      attacker:=player_NAME;
      target_HP:=enemy_HP;
      target_AHP:=enemy_AHP;
      attacker_DMG:=player_DMG;
      target_ARMOR:=enemy_ARMOR;
      target_DODGE:=enemy_DODGE;
      target_BLOCK:=enemy_BLOCK;
      target_BLOCKDMG:=enemy_BLOCKDMG;
      attacker_CritChance:=player_CritChance;
      attacker_CritDMG:=player_CritDMG;
    end;
    if not(odd(i)) then                       //чёт  2/4/6
    begin
      attacker:=enemy_NAME;
      target:=player_NAME;
      target_HP:=player_HP;
      target_AHP:=player_AHP;
      attacker_DMG:=enemy_DMG;
      target_ARMOR:=player_ARMOR;
      target_DODGE:=player_DODGE;
      target_BLOCK:=player_BLOCK;
      target_BLOCKDMG:=player_BLOCKDMG;
      attacker_CritChance:=enemy_CritChance;
      attacker_CritDMG:=enemy_CritDMG;
    end;
    nRand:=RandomRange(0,101);
    if ((nRand+attacker_CritChance)>=100) then  begin     ICrit:=true; end;
    nRand:=RandomRange(0,101);
    if ((nRand+target_BLOCK)>=100) then       begin      IBlock:=true;     end;
    nRand:=RandomRange(0,101);
    if ((nRand+target_DODGE)>=100) then        begin     IDodge:=true;     end;
    if ((ICrit=true) and (IBlock=false)) then            // (Крит без блока) уворот не важен          + - -/+
    begin
      target_AHP:=target_AHP-attacker_DMG*Ceil(attacker_CritDMG/100);
      RichMemo1.Lines.Add(attacker+' наносит критический удар обойдя защиту '+target+' ! '+ IntToStr(attacker_DMG*Ceil(attacker_CritDMG/100))+' урона! '+target+ '('+IntToStr(target_AHP)+'/'+IntToStr(target_HP)+')');
    end;
    if ((IDodge=false) and (IBlock=false) and (ICrit=false)) then  //  (обычная атака)   - - -
    begin
      if (attacker_DMG>target_ARMOR) then                            //урона больше чем брони
      begin
        target_AHP:=target_AHP-(attacker_DMG-target_ARMOR);
        RichMemo1.Lines.Add(attacker+' наносит '+ IntToStr(attacker_DMG-target_ARMOR)+' урона. '+target+ '('+IntToStr(target_AHP)+'/'+IntToStr(target_HP)+')');
      end;
      if (attacker_DMG<=target_ARMOR) then                                                        //брони больше чем урона
      begin
        target_AHP:=target_AHP-Ceil(attacker_DMG/DMGReductionArmor);
        RichMemo1.Lines.Add(attacker+' с трудом пробивает защиту и наносит '+ IntToStr(Ceil(attacker_DMG/DMGReductionArmor))+' урона... '+target+ '('+IntToStr(target_AHP)+'/'+IntToStr(target_HP)+')');
      end;
    end;
  if ((IDodge=false) and (IBlock=true)) then                             //крит не важен, блок, и не уворот  +/- + -
  begin
    if attacker_DMG>target_BlockDMG then
    begin
      target_AHP:=target_AHP-(attacker_DMG-target_BlockDMG);
      RichMemo1.Lines.Add(attacker+' наносит лишь '+IntToStr(attacker_DMG-target_BlockDMG)+' урона, ибо '+target+'('+IntToStr(target_AHP)+'/'+IntToStr(target_HP)+') блокирует.');
    end
    else
      RichMemo1.Lines.Add(target+' полностью блокирует весь урон!');
  end;
  if ((IDodge=true) and (ICrit=false)) then   //уворот
  begin
    RichMemo1.Lines.Add(attacker+' промахивается, '+ target+ '('+IntToStr(target_AHP)+'/'+IntToStr(target_HP)+') уворачивается!');
  end;
  if odd(i) then begin  enemy_AHP:=target_AHP; end;  //нечёт   (player)
  if not(odd(i)) then begin   player_AHP:=target_AHP; end;//чёт    (mob)
  if (target_AHP<=0) then
  begin
    RichMemo1.Lines.Add(attacker +' одерживает победу! '+ target +  ' - поражение.');
    if attacker=player_NAME then
    begin
      EXP_GAIN(enemy_EXP);
      for j:=1 to MaxActiveQuests do
      begin
        if Quest[QuestProgress[j,1],3]=IntToStr(MobID) then
          QuestProgress[j,2]:=QuestProgress[j,2]+1;
      end;
      for d:=1 to MaxDrops do
      begin
        if not(DropList[MobID,d]='') then
        begin
          DropChance:=StrToInt(Items[16,StrToInt(DropList[MobID,d])]);  // DropList[MobID,d]  id of droped item
          if RandomRange(0,101)+DropChance>100 then
          begin
            PickItem(StrToInt(DropList[MobID,d]));
          end;
        end;
      end;
    end
    else
      player_AHP:=0;
    break;
    end;
  end;
end;

//при получении опыта
procedure TForm1.EXP_GAIN(EXP_amount: integer);
begin
player_EXP:= player_EXP + EXP_amount;
while player_EXP >= LevelFormula do
        begin
          player_EXP:= player_EXP - LevelFormula;
          player_LEVEL:= player_LEVEL + 1;
          StatReload();
          player_statpoint:= player_statpoint + StatPointPerLevel;
          player_AHP:= player_HP;
          RichMemo1.Lines.Add(player_NAME+' достигает '+IntToStr(player_LEVEL)+'-го уровня и теперь имеет полное здоровье! Свободные характеристики: '+IntToStr(player_statpoint));
          StatPointsButtonsActive();
          Sleep(250);
        end;
GroupBox1.Caption:= 'Повышение навыков, доступно ('+ IntToStr(player_StatPoint) +')';
end;

//procedure StatsMod
procedure TForm1.StatMod();
var i:integer;
begin
SMP_OFFENCE    :=0;
SMP_DEFENCE    :=0;
SMP_OBSERVATION:=0;
SMP_HP         :=0;
SMP_DMG        :=0;
SMP_ARMOR      :=0;
SMP_DODGE      :=0;
SMP_BLOCK      :=0;
SMP_BLOCKDMG   :=0;
SMP_CritChance :=0;
SMP_CritDMG    :=0;
for i:=1 to EquipmentCount do
begin
SMP_OFFENCE    :=SMP_OFFENCE    +StrToInt(Items[4 ,StrToInt(Equipment[i])]);  //
SMP_DEFENCE    :=SMP_DEFENCE    +StrToInt(Items[5 ,StrToInt(Equipment[i])]);
SMP_OBSERVATION:=SMP_OBSERVATION+StrToInt(Items[6 ,StrToInt(Equipment[i])]);
SMP_HP         :=SMP_HP         +StrToInt(Items[7 ,StrToInt(Equipment[i])]);
SMP_DMG        :=SMP_DMG        +StrToInt(Items[8 ,StrToInt(Equipment[i])]);  //Items[,equipment[i]]
SMP_ARMOR      :=SMP_ARMOR      +StrToInt(Items[9 ,StrToInt(Equipment[i])]);
SMP_DODGE      :=SMP_DODGE      +StrToInt(Items[10,StrToInt(Equipment[i])]);
SMP_BLOCK      :=SMP_BLOCK      +StrToInt(Items[11,StrToInt(Equipment[i])]);
SMP_BLOCKDMG   :=SMP_BLOCKDMG   +StrToInt(Items[12,StrToInt(Equipment[i])]);
SMP_CritChance :=SMP_CritChance +StrToInt(Items[13,StrToInt(Equipment[i])]);
SMP_CritDMG    :=SMP_CritDMG    +StrToInt(Items[14,StrToInt(Equipment[i])]);
//  RichMemo1.Lines.Add(Items[4 ,StrToInt(Equipment[i])]);
end;
end;

//test menu
procedure TForm1.MenuItem8Click(Sender: TObject);
begin  //  RichMemo1.Lines.Add(IntToStr(DiceRoll(2,6)));
  PickItem(1);
end;

procedure TForm1.MenuItem9Click(Sender: TObject);
begin
InterfaceState(0);
PlayerInfo();
end;

//Функция рола дайсов (колво дайсов, колво граней дайсов, бонус)
function TForm1.DiceRoll(dices, faces :integer) :integer;
var i:integer;
begin
Result:=0;
for i:=1 to dices do
  begin
  Result:=Result+RandomRange(1,faces+1);
  end;
end;

//Формула рассчёта уровня и опыта для след.уровня
function TForm1.LevelFormula :integer;
begin
  LevelFormula:=3+player_LEVEL*2;    // level formula easy to change
end;

//Формула рассчёта шанса крита
function TForm1.CritFormula    : integer;
var i:integer;
  s:real;
begin
    s:=5;
    Result:=Round(s);
    for i:=2 to MP_OFFENCE do
    begin
      s:=s/1.062; // 80 max, s = 5,  ~60 iterations+, s/1.062
      Result:=Result+Round(s);
    end;
end;

//Формула рассчёта шанса уворота
function TForm1.DodgeFormula   : integer;
var i:integer;
  s:real;
begin
  s:=5;
  Result:=Round(s);
  for i:=2 to MP_OBSERVATION do
  begin
    s:=s/1.062; // 80 max, s = 5,  ~60 iterations+, s/1.062
    Result:=Result+Round(s);
  end;
end;

//Формула рассчёта шанса блока
function TForm1.BlockFormula   : integer;
var i:integer;
  s:real;
begin
    s:=2;
    Result:=Round(s);
    for i:=2 to MP_DEFENCE do
    begin
      s:=s/1.05; // 35 max, s = 2, ~30 iterations+ , s/1.05   это для блока шанса
      Result:=Result+Round(s);
    end;
end;

//Действия при клике по инвентарю
procedure TForm1.StringGrid3MouseUp(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
var ThisCell : TPoint;
begin
  ThisCell := StringGrid3.MouseToCell(Point(X, Y));
      if (ThisCell.Y>0) and (ThisCell.X=2) then
      begin
        if CheckBox1.Checked then
        DropItemSlot(ThisCell.Y,true)
        else
        DropItemSlot(ThisCell.Y,false);
        InventoryFill();
      end;
      if (ThisCell.Y>0) and (ThisCell.X=0) then
      begin
        EquipOrUseItem(StrToInt(Inventory[ThisCell.Y]));
      end;
end;


    //      Узнать какая ячейка выделена в стринггриде по клику мыши ("отпускание")
   ///////////////////////////////Найти схожее под энтер на клаве
procedure TForm1.StringGrid1MouseUp(Sender: TObject; Button: TMouseButton;
   Shift: TShiftState; Y: Integer);
 var ThisCell : TPoint; Ssize:integer;
 begin
                Sleep(200);
   ThisCell := StringGrid1.MouseToCell(Point(0, Y));
       if ThisCell.Y>0 then
       begin
            CurrentLocation:=StrToInt(LocAccNow[ThisCell.Y]);
               LocationChange();
       end;
   for y:=1 to NowLocCount do
   begin
        LocAccNow[y]:='0';
   end;
   for y:=1 to NowMobCount do
   begin
        MobsOnLoc[y]:='0';
   end;
   LocationFill();
   MobsOnLocation();
  StringGrid1.AutoSizeColumns;
  Ssize:=0;
  for y:=0 to StringGrid1.ColCount-1 do
  Ssize:=Ssize+StringGrid1.ColWidths[y];
  StringGrid1.Width:=Ssize+5;
 end;

//Клик по стринггрид2 + вызов боёвки
procedure TForm1.StringGrid2MouseUp(Sender: TObject; Button: TMouseButton;
   Shift: TShiftState; Y: Integer);
 var ThisCell : TPoint;
 begin
   ThisCell := StringGrid2.MouseToCell(Point(0, Y));
       if ThisCell.Y>0 then
       begin
       Battle(StrToInt(MobsOnLoc[ThisCell.Y]));
       Sleep(500);
       end;
 end;

//Вызов подключения к БД - загрузки оттуда массивов - заполнения характеристик игрока
//(включая айди текущей локации)....
procedure TForm1.LoadData();
begin
  RPGSQLConnection();
  RPGSQLLoadData();
  RPGSQLLoadPlayerData(1);
  PlayerStatsLoad();
  DropListArray();
  QuestProgressToArrays();
end;

//Процедура заполнения стринггрида2 с мобами
procedure TForm1.MobsOnLocation();
  var S,i: Integer;
begin
  StringGrid2.Cells[0,0]:='Здесь есть:';
  StringGrid2.FixedColor:=$00F6F6F6;       // Цвет фиксированной ячейки
  StringGrid2.Constraints.MaxHeight:= 270; //250 на 10 строк по 22высотой каждая ячейка
  StringGrid2.FixedRows:=1;                //Закреплённая (название)
  StringGrid2.FixedCols:=0;
  NowMobCount:=1;
  if not(LocMobs[CurrentLocation][1]='0') then
  begin
    for i:=1 to Length(LocMobs[CurrentLocation]) do
    begin
      if not(LocMobs[CurrentLocation][i]=' ') then
      begin
        MobsOnLoc[NowMobCount]:=MobsOnLoc[NowMobCount]+LocMobs[CurrentLocation][i];
      end;
      if (LocMobs[CurrentLocation][i]=' ') then
      begin
        NowMobCount:=NowMobCount+1;
      end;
    end;
    StringGrid2.RowCount:=NowMobCount+1;
    for i:=1 to NowMobCount do
    StringGrid2.Cells[0,i]:=AMobs[StrToInt(MobsOnLoc[i]),1]; //i 1.. -номер моба j  1.. - номер характеристики
  end
  else
  begin
    NowMobCount:=0;
    StringGrid2.RowCount:=1;
    StringGrid2.Cells[0,0]:='Здесь нет монстров.';
    StringGrid2.AutoSizeColumns;
    StringGrid2.Height:=StringGrid2.RowHeights[0]+5;
    StringGrid2.Width:=StringGrid2.ColWidths[0]+5;
  end;
  StringGrid2.AutoSizeColumns;
  if (NowMobCount<=NowLocCount) and not(NowMobCount=0) then
  begin
    StringGrid2.Height:=StringGrid2.RowHeights[0] * (NowMobCount+1)+5;
    StringGrid2.Width:=StringGrid2.ColWidths[0]+5;
  end;
  if (NowMobCount>NowLocCount) and not(NowMobCount=0) then
  begin
    StringGrid2.Height:=StringGrid2.RowHeights[0] * (NowLocCount+1)+5;
    StringGrid2.Width:=StringGrid2.ColWidths[0]+5;
  end;
   StringGrid2.Height:=StringGrid2.RowHeights[0]*(NowMobCount+1)+5;
   S:=0;
   StringGrid1.AutoSizeColumns;
   for i:=0 to StringGrid1.ColCount-1 do
  S:=S+StringGrid1.ColWidths[i];
  StringGrid1.Width:=S+5;
end;

//Подключение к БД
procedure TForm1.RPGSQLConnection();
begin
  SQLite3Connection1.DatabaseName := 'data\RPGproject.db'; // указывает путь к базе
  SQLite3Connection1.CharSet := 'UTF8';                   // указываем рабочую кодировку
  SQLite3Connection1.Transaction := SQLTransaction1;     // указываем менеджер транзакций
  try                                                   // пробуем подключится к базе
    SQLite3Connection1.Open;
    SQLTransaction1.Active := True;
  except                                             // если не удалось то выводим сообщение о ошибке
    ShowMessage('Ошибка подключения к базе!');
  end;
end;

//Загрузка из SQLя и выгрузка данных в массивы AMobs (мобы), LocNames(локации назв.)
// LocAccess(доступные локи), LocMobs(мобы на локах)
procedure TForm1.RPGSQLLoadData();
  var i : Integer;
begin
////////////////////////////Mobs from SQL
  SQLQuery1.Close;
  SQLQuery1.SQL.Text:='SELECT * FROM Mobs';
  SQLQuery1.Open;
  i:=1;
  while not SQLQuery1.Eof do
    begin                  //AMobs[1..99,1..9] [id,params]
      AMobs[i,1]:=SQLQuery1.FieldByName('mName').AsString;
      AMobs[i,2]:=SQLQuery1.FieldByName('mHP').AsString;
      AMobs[i,3]:=SQLQuery1.FieldByName('mDMG').AsString;
      AMobs[i,4]:=SQLQuery1.FieldByName('mArmor').AsString;
      AMobs[i,5]:=SQLQuery1.FieldByName('mDodge').AsString;
      AMobs[i,6]:=SQLQuery1.FieldByName('mBlock').AsString;
      AMobs[i,7]:=SQLQuery1.FieldByName('mBlockDMG').AsString;
      AMobs[i,8]:=SQLQuery1.FieldByName('mCrit').AsString;
      AMobs[i,9]:=SQLQuery1.FieldByName('mCritDMG').AsString;
      AMobs[i,10]:=SQLQuery1.FieldByName('mEXP').AsString;
      AMobs[i,11]:=SQLQuery1.FieldByName('mItemsDrop').AsString;
      SQLQuery1.Next;
      i:=i+1;
    end;

////////////////////////locations from SQL
  SQLQuery1.Close;
  SQLQuery1.SQL.Text:='SELECT * FROM Locations';
  SQLQuery1.Open;
  i:=1;
  while not SQLQuery1.Eof do
    begin
      LocNames[i]:=SQLQuery1.FieldByName('LocName').AsString;
      LocAccess[i]:=SQLQuery1.FieldByName('LocAccess').AsString;
      LocMobs[i]:=SQLQuery1.FieldByName('MobsOnLoc').AsString;
      SQLQuery1.Next;
      i:=i+1;
    end;

  ////////////////////////locations from SQL
    SQLQuery1.Close;
    SQLQuery1.SQL.Text:='SELECT * FROM Quests';
    SQLQuery1.Open;
    i:=1;
    while not SQLQuery1.Eof do
      begin
        Quest[i,1]:=SQLQuery1.FieldByName('qName').AsString;
        Quest[i,2]:=SQLQuery1.FieldByName('qDescription').AsString;
        Quest[i,3]:=SQLQuery1.FieldByName('qMobID').AsString; //    QuestRequirements[i,1]
        Quest[i,4]:=SQLQuery1.FieldByName('qMobKill').AsString; //   QuestRequirements[i,2]
        Quest[i,5]:=SQLQuery1.FieldByName('qItemID').AsString;    //  QuestRequirements[i,3]
        Quest[i,6]:=SQLQuery1.FieldByName('qItemCount').AsString;   // QuestRequirements[i,4]
        Quest[i,7]:=SQLQuery1.FieldByName('qRewardXP').AsString;     //QuestRewards[i,1]
        Quest[i,8]:=SQLQuery1.FieldByName('qRewardCoin').AsString;    //QuestRewards[i,2]
        Quest[i,9]:=SQLQuery1.FieldByName('qRewardItemID').AsString;     //QuestRewards[i,3]
        SQLQuery1.Next;
        i:=i+1;
      end;

  ///////////////////////////////////////////////
    SQLQuery1.Close;
  SQLQuery1.SQL.Text:='SELECT * FROM Items';
  SQLQuery1.Open;
  i:=1;
  while not SQLQuery1.Eof do
    begin
    Items[1,i]:= SQLQuery1.FieldByName('iName').AsString;
    Items[2,i]:= SQLQuery1.FieldByName('iType').AsString;
    Items[3,i]:= SQLQuery1.FieldByName('iEffects').AsString;
    Items[4,i]:= SQLQuery1.FieldByName('iOFF').AsString;
    Items[5,i]:= SQLQuery1.FieldByName('iDEF').AsString;
    Items[6,i]:= SQLQuery1.FieldByName('iOBS').AsString;
    Items[7,i]:= SQLQuery1.FieldByName('iHP').AsString;
    Items[8,i]:= SQLQuery1.FieldByName('iDMG').AsString;
    Items[9,i]:= SQLQuery1.FieldByName('iARMOR').AsString;
    Items[10,i]:=SQLQuery1.FieldByName('iDODGE').AsString;
    Items[11,i]:=SQLQuery1.FieldByName('iBLOCKCHANCE').AsString;
    Items[12,i]:=SQLQuery1.FieldByName('iBLOCKDMG').AsString;
    Items[13,i]:=SQLQuery1.FieldByName('iCRITCHANCE').AsString;
    Items[14,i]:=SQLQuery1.FieldByName('iCRITDMG').AsString;
    Items[15,i]:=SQLQuery1.FieldByName('iVALUE').AsString;
    Items[16,i]:=SQLQuery1.FieldByName('iDrop').AsString;

//    Items[16,i]:=SQLQuery1.FieldByName('i').AsString;
      SQLQuery1.Next;
      i:=i+1;
    end;
    SQLQuery1.Close;
 end;

//////////////////////////Player from SQL
procedure TForm1.RPGSQLLoadPlayerData(PlayerLoadID:integer);
  var i : Integer;
begin
  SQLQuery1.Close;
  SQLQuery1.SQL.Text:='SELECT * FROM Player WHERE Player.pID='+IntToStr(PlayerLoadID);
  SQLQuery1.Open;
  i:=1;
  while not SQLQuery1.Eof do
    begin         //playerstat ^pName,pCLID,pCHP,pHP,pDMG,pArmor,pDodge,pBlock,pCrit,pCritDMG (1..10)
      PlayerStat[1]:=SQLQuery1.FieldByName('pName').AsString;
      PlayerStat[2]:=SQLQuery1.FieldByName('pCLID').AsString;
      PlayerStat[3]:=SQLQuery1.FieldByName('pAHP').AsString;
      PlayerStat[4]:=SQLQuery1.FieldByName('pEXP').AsString;
      PlayerStat[5]:=SQLQuery1.FieldByName('pLVL').AsString;
      PlayerStat[6]:=SQLQuery1.FieldByName('pOFF').AsString;
      PlayerStat[7]:=SQLQuery1.FieldByName('pDEF').AsString;
      PlayerStat[8]:=SQLQuery1.FieldByName('pOBS').AsString;
      PlayerStat[9]:=SQLQuery1.FieldByName('pFSP').AsString;
      PlayerStat[10]:=SQLQuery1.FieldByName('pEQI').AsString;
      PlayerStat[11]:=SQLQuery1.FieldByName('pINVENTORY').AsString;
      PlayerStat[12]:=SQLQuery1.FieldByName('pItemStack').AsString;
      PlayerStat[13]:=SQLQuery1.FieldByName('pCoins').AsString;
      PlayerStat[14]:=SQLQuery1.FieldByName('pActiveQuests').AsString;
      SQLQuery1.Next;
      i:=i+1;
    end;
    SQLQuery1.Close;
end;

//Загрузка параметров игрока из массива в переменные
procedure Tform1.PlayerStatsLoad();
begin
  player_NAME:=       PlayerStat[1];
  CurrentLocation:=   StrToInt(PlayerStat[2]);
  player_AHP:=        StrToInt(PlayerStat[3]);
  player_EXP:=        StrToInt(PlayerStat[4]);
  player_LEVEL:=      StrToInt(PlayerStat[5]);
  player_OFFENCE:=    StrToInt(PlayerStat[6]);
  player_DEFENCE:=    StrToInt(PlayerStat[7]);
  player_OBSERVATION:=StrToInt(PlayerStat[8]);
  player_StatPoint:=  StrToInt(PlayerStat[9]);
  player_Equipment:=  PlayerStat[10];
  player_Inventory:=  PlayerStat[11];
  player_ItemStack:=  PlayerStat[12];
  player_Coins:=      StrToInt(PlayerStat[13]);
  player_QuestProgress:=PlayerStat[14];
  ItemsToArrays();
  StatReload();
end;


//Сохранение персонажа в SQL
procedure TForm1.PlayerSave(SaveID:integer);
begin
SQLQuery1.Close;
SQLQuery1.SQL.Text:='SELECT * FROM Player WHERE Player.pID='+IntToStr(SaveID);
SQLQuery1.Open;
SQLQuery1.Edit;
SQLQuery1.FieldByName('pName').AsString:=player_NAME;
SQLQuery1.FieldByName('pCLID').AsInteger:=CurrentLocation;
SQLQuery1.FieldByName('pAHP').AsInteger:=player_AHP;
SQLQuery1.FieldByName('pEXP').AsInteger:=player_EXP;
SQLQuery1.FieldByName('pLVL').AsInteger:=player_Level;
SQLQuery1.FieldByName('pOFF').AsInteger:=player_OFFENCE;
SQLQuery1.FieldByName('pDEF').AsInteger:=player_DEFENCE;
SQLQuery1.FieldByName('pOBS').AsInteger:=player_OBSERVATION;
SQLQuery1.FieldByName('pFSP').AsInteger:=player_StatPoint;
SQLQuery1.FieldByName('pEQI').AsString:=player_Equipment;
SQLQuery1.FieldByName('pINVENTORY').AsString:=player_Inventory;
SQLQuery1.FieldByName('pItemStack').AsString:=player_ItemStack;
SQLQuery1.FieldByName('pCoins').AsInteger:=player_Coins;
SQLQuery1.FieldByName('pActiveQuests').AsString:=player_QuestProgress;
SQLQuery1.Post;
SQLQuery1.ApplyUpdates;
SQLTransaction1.Commit;
SQLQuery1.Close;
end;

//Заполнение StringGrid1 локациями
procedure TForm1.LocationFill();
var
 i:Integer;
begin
  if LocNames[CurrentLocation]='0' then
  begin
     ShowMessage('Локация с таким айди не найдена, Вас перенесёт в Лес');
     CurrentLocation:=1;
  end;
    if (LocAccess[CurrentLocation]='0') then
                begin
                  ShowMessage('Это окончательная тупиковая локация, из неё нет выхода, Вас перенесёт в Лес');
                  CurrentLocation:=1;
                end;
  StringGrid1.Cells[0,0]:=LocNames[CurrentLocation];
  StringGrid1.FixedColor:=$00F6F6F6;       // Цвет фиксированной ячейки
//  StringGrid1.Constraints.MaxHeight:= 270; //250 на 10 строк по 22высотой каждая ячейка
  StringGrid1.FixedRows:=1;                //Закреплённая (название)
  StringGrid1.FixedCols:=0;
  NowLocCount:=1;                           //Дефолтное кол-во цифер в числе
  for i:=1 to Length(LocAccess[CurrentLocation]) do
  begin
    if not(LocAccess[CurrentLocation][i]=' ') then
      LocAccNow[NowLocCount]:=LocAccNow[NowLocCount]+LocAccess[CurrentLocation][i];
    if (LocAccess[CurrentLocation][i]=' ') then
      NowLocCount:=NowLocCount+1;
       StringGrid1.AutoSizeColumns;
  end;
  StringGrid1.RowCount:=NowLocCount+1; // потому что лока в которой ты находишься там уже есть
  for i:=1 to NowLocCount do
  begin
    StringGrid1.Cells[0,i]:=LocNames[StrToInt(LocAccNow[i])];
       StringGrid1.AutoSizeColumns;
  end;
// Ширина стринггрида1 в зависимости от заполнения и его высотаы
StringGrid1.AutoSizeColumns;
StringGrid1.AutoSizeColumn(0);
   if LAL<6 then begin StringGrid1.Width:=StringGrid1.ColWidths[0]+5; end;
   if LAL>=6 then begin StringGrid1.Width:=StringGrid1.ColWidths[0]+25; end;
   StringGrid1.Height:=StringGrid1.RowHeights[0]*(NowLocCount+1)+5;

end;

//Очистка ричмемо
procedure TForm1.MenuItem5Click(Sender: TObject);
begin
RichMemo1.Clear;
end;

//Действия с формой

//При создании формы
procedure TForm1.FormCreate(Sender: TObject);
// Создание формы, процедура в которой вызывать остальные процедуры
begin
  Form1.Caption:='RPGproject';
  Randomize;
  LAL:=0;
  LoadData();              //Вызываем 1 раз
  RichMemo1.clear;
  RichMemo1.Lines.Add('С возвращением, '+player_NAME+'('+IntToStr(player_AHP)+'/'+IntToStr(player_HP)+')'+' !');
  LocationFill();
  MobsOnLocation();
  GroupBox1.Caption:= 'Повышение навыков, доступно ('+ IntToStr(player_StatPoint) +')';
  GroupBox2.Caption:='Инвентарь';
  StringGrid3.FixedCols:=0;
  StringGrid3.FixedRows:=1;
  StringGrid3.Cells[0,0]:='Название предмета';
  Button1.Caption:='Нападение';
  Button2.Caption:='Защита';
  Button3.Caption:='Наблюдение';
  InterfaceState(0);
end;


//Прячем окошко прокачки статов
procedure TForm1.ZeroStatPoints();
begin
GroupBox1.Hide;
end;

//Показываем окошко прокачки статов
procedure TForm1.StatPointsButtonsActive();
begin
GroupBox1.Show;
end;

//При закрытии формы
procedure TForm1.FormClose(Sender: TObject; var CloseAction: TCloseAction);
begin
  ArraysToItems();
  QuestProgressSave();
  PlayerSave(1);
end;

//Кнопки

//Конпки прокчки статов
procedure TForm1.Button1Click(Sender: TObject);
begin
  if player_StatPoint>0 then
  begin
  player_OFFENCE:=player_OFFENCE+1;
  player_StatPoint:=player_StatPoint-1;
  PlayerInfo();
    if player_StatPoint=0 then  ZeroStatPoints();
  end
  else
  ZeroStatPoints();
  GroupBox1.Caption:= 'Повышение навыков, доступно ('+ IntToStr(player_StatPoint) +')';
  delay(150);
end;

procedure TForm1.Button2Click(Sender: TObject);
begin
  if player_StatPoint>0 then
  begin
  player_DEFENCE:=player_DEFENCE+1;
  player_StatPoint:=player_StatPoint-1;
  PlayerInfo();
      if player_StatPoint=0 then  ZeroStatPoints();
  end
  else
  ZeroStatPoints();
  GroupBox1.Caption:= 'Повышение навыков, доступно ('+ IntToStr(player_StatPoint) +')';
  delay(150);
end;

procedure TForm1.Button3Click(Sender: TObject);
begin
  if player_StatPoint>0 then
  begin
  player_OBSERVATION:=player_OBSERVATION+1;
  player_StatPoint:=player_StatPoint-1;
  PlayerInfo();
      if player_StatPoint=0 then  ZeroStatPoints();
  end
  else
  ZeroStatPoints();
  GroupBox1.Caption:= 'Повышение навыков, доступно ('+ IntToStr(player_StatPoint) +')';
  delay(150);
end;

//Пункты главного меню

//Инвентарь
procedure TForm1.MenuItem10Click(Sender: TObject);
begin
  InventoryFill();
  InterfaceState(1);
end;

//Заполнение стринггрида инвентаря
procedure TForm1.InventoryFill();
var SGSZ,i:integer;
begin
InventorySort();
StringGrid3.ColCount:=3;
StringGrid3.RowCount:=ItemsInInventory+1;
for i:=1 to ItemsInInventory do
begin                                        //StringGrid3.Cells[,]
  if StrToInt(ItemStack[i])>1 then
StringGrid3.Cells[0,i]:=Items[1,StrToInt(Inventory[i])]+' ('+ItemStack[i]+')';
if StrToInt(ItemStack[i])=1 then
StringGrid3.Cells[0,i]:=Items[1,StrToInt(Inventory[i])];

StringGrid3.Cells[1,i]:=ItemDescription(StrToInt(Inventory[i]));
StringGrid3.Cells[2,i]:='Выкинуть';
end;
StringGrid3.Cells[1,0]:='Характеристики';
StringGrid3.Cells[2,0]:='Действие';
StringGrid3.AutoSizeColumns;
  SGSZ:=0;
  for i:=0 to StringGrid3.ColCount-1 do
  begin
  SGSZ:= SGSZ + StringGrid3.ColWidths[i];
  end;
  StringGrid3.Width:=SGSZ+5;
  SGSZ:=0;
  for i:=0 to StringGrid3.RowCount-1 do
  begin
  SGSZ:= SGSZ + StringGrid3.RowHeights[i];
  end;
  StringGrid3.Height:=SGSZ+5;
end;

//восстанавливаем здоровъе
procedure TForm1.MenuItem7Click(Sender: TObject);
begin
  RichMemo1.Lines.Add('Здоровье восстановлено '+player_NAME+'('+IntToStr(player_HP)+'/'+IntToStr(player_HP)+').');
  player_AHP:=player_HP;
end;


//Сброс персонажа
procedure TForm1.MenuItem6Click(Sender: TObject);
begin
  ResetPlayerStats();
end;

//процедура сброса персонажа
procedure TForm1.ResetPlayerStats();
begin
player_NAME:='Li4KinG';
CurrentLocation:=1;
player_EXP:=0;
player_LEVEL:=1;
player_OFFENCE:=1;
player_DEFENCE:=1;
player_OBSERVATION:=1;
player_StatPoint:=1;
player_Equipment:='2 3 4';
player_Inventory:='1 5 6';
player_ItemStack:='1 1 1';
player_QuestProgress:='0 0;';
player_Coins:=10;
ItemsToArrays();
StatReload();
InventoryFill();
QuestProgressToArrays();
RichMemo1.lines.Add('Персонажу '+player_NAME+'('+IntToStr(player_LEVEL)+') был восстановлен начальный уровень и характеристиками.');
player_AHP:=player_HP;
StatPointsButtonsActive();
PlayerInfo();
end;


//Настройки
procedure TForm1.MenuItem2Click(Sender: TObject);
begin

end;

//Выход
procedure TForm1.MenuItem3Click(Sender: TObject);
begin
  Form1.Close;
end;

//Персонаж
procedure TForm1.MenuItem4Click(Sender: TObject);
begin

end;

//инфо о персонаже
procedure TForm1.PlayerInfo();
begin
StatReload();
RichMemo1.Lines.Add('--------------------------------------');
 RichMemo1.Lines.Add('Имя персонажа: '+player_Name+' '+IntToStr(player_LEVEL)+'-го уровня. Опыт: '+IntToStr(player_EXP)+'/'+IntToStr(LevelFormula)+'.');
 RichMemo1.Lines.Add('Оружие: '+Items[1,StrToInt(Equipment[1])]+'.');
 RichMemo1.Lines.Add('Броня: '+Items[1,StrToInt(Equipment[2])]+'.');
 RichMemo1.Lines.Add('Щит: '+Items[1,StrToInt(Equipment[3])]+'.');
  RichMemo1.Lines.Add('Здоровье: '+ IntToStr(player_AHP) +'/'+IntToStr(player_HP));
   RichMemo1.Lines.Add('Навыки (Свободные очки '+IntToStr(player_statpoint)+'):');
   RichMemo1.Lines.Add('Навык нападения: '+IntToStr(MP_OFFENCE)+' ('+IntToStr(player_OFFENCE)+'+'+IntToStr(MP_OFFENCE-player_OFFENCE)+')');
   RichMemo1.Lines.Add('Навык защиты: '+IntToStr(MP_DEFENCE)+' ('+IntToStr(player_DEFENCE)+'+'+IntToStr(MP_DEFENCE-player_DEFENCE)+')');
   RichMemo1.Lines.Add('Навык наблюдения: '+IntToStr(MP_OBSERVATION)+' ('+IntToStr(player_OBSERVATION)+'+'+IntToStr(MP_OBSERVATION-player_OBSERVATION)+')');
   RichMemo1.Lines.Add('Боевые характеристики:');
    RichMemo1.Lines.Add('Урон: '+IntToStr(player_DMG));
     RichMemo1.Lines.Add('Броня: '+IntToStr(player_ARMOR));
      RichMemo1.Lines.Add('Уворот: '+IntToStr(player_DODGE)+'%');
       RichMemo1.Lines.Add('Блок: '+IntToStr(player_BLOCK)+'%');
        RichMemo1.Lines.Add('Блокируемый урон: '+IntToStr(player_BLOCKDMG));
         RichMemo1.Lines.Add('Шанс крита: '+IntToStr(player_CritChance)+'%');
          RichMemo1.Lines.Add('Сила крита: '+IntToStr(player_CritDMG)+'%');
          RichMemo1.Lines.Add('--------------------------------------');
end;


//Другие функции и процедуры

//При смене локации выполняется это
procedure TForm1.LocationChange();
  var i: Integer;
begin
  i:=RandomRange(0,7);
  case i of
    0: RichMemo1.Lines.Add('Спустя некоторое время цель достигнута и перед взором '+LocNames[CurrentLocation]+'.');
    1: RichMemo1.Lines.Add('Дорога, наконец, приводит к месту, именуемому местными не иначе, как "'+ LocNames[CurrentLocation]+ '".');
    2: RichMemo1.Lines.Add('Попутчик-незнакомец рассказал интересную историю. А вот и '+ LocNames[CurrentLocation]+ '. Время в дороге пролетело незаметно.');
    3: RichMemo1.Lines.Add('Кажется '+LocNames[CurrentLocation]+ ' выглядит как-то необычно... Хотя, может, это всего-лишь воображение?');
    4: RichMemo1.Lines.Add('Неужели это '+LocNames[CurrentLocation]+ '? Путь занял даже меньше времени чем планировалось!');
    5: RichMemo1.Lines.Add('Странно, '+LocNames[CurrentLocation]+', а вокруг никого, с кем можно было бы поболтать.');
    6: RichMemo1.Lines.Add('Наконец-то, '+LocNames[CurrentLocation]+'! Добрались без проишествий.');
  end;
end;

//Для ввода кусков текста разных цветов
procedure TForm1.AddColorStr(s: string; const col: TColor = clBlack; const NewLine: boolean = TRUE);
begin
  with RichMemo1 do
  begin
    if NewLine then
    begin
      Lines.Add('');
      Lines.Delete(Lines.Count - 1); // avoid double line spacing
    end;
    SelStart  := Length(Text);
    SelText   := s;
    SelLength := Length(s);
    SetRangeColor(SelStart, SelLength, col);
    // deselect inserted string and position cursor at the end of the text
    SelStart  := Length(Text);
    SelText   := '';
  end;
end;

//процедуры связанные с характеристиками персонажа и их изменениями


//процедура которую применяем для пересчёта характеристик шанса крита/уворота/блока/
//максимального здоровья/силы крита/защиты
procedure TForm1.StatReload();
begin
  StatMod();
  MP_OFFENCE:=player_OFFENCE                + SMP_OFFENCE;
  MP_DEFENCE:=player_DEFENCE                + SMP_DEFENCE;
  MP_OBSERVATION:=player_OBSERVATION        + SMP_OBSERVATION;
if player_HP<=player_AHP then
begin
  player_HP:=10+player_LEVEL*5              + SMP_HP;
  player_AHP:=player_HP;
end
  else   player_HP:=12+player_LEVEL*3       + SMP_HP;
player_DMG:= 2 + 1 * MP_OFFENCE             + SMP_DMG;
player_ARMOR:= 1 * MP_DEFENCE               + SMP_ARMOR;
player_DODGE:= DodgeFormula                 + SMP_DODGE;
player_BLOCK:= BlockFormula                 + SMP_BLOCK;
player_CritChance:= CritFormula             + SMP_CRITCHANCE;
player_CritDMG:= 100 + 10 * MP_OBSERVATION  + SMP_CRITDMG;
player_BlockDMG:= 2 * MP_DEFENCE            + SMP_BLOCKDMG;
GroupBox1.Caption:= 'Повышение навыков, доступно ('+ IntToStr(player_StatPoint) +')';
if player_StatPoint>0 then
GroupBox1.Show
else
GroupBox1.hide;
end;


end.
{
Lines.Add('Line in red');
      SetRangeColor(Length(Lines.Text) - Length(Lines[Lines.Count - 1]) - Lines.Count - 1, Length(Lines[Lines.Count - 1]), clRed);

      Lines.Add('Line in blue');
      SetRangeColor(Length(Lines.Text) - Length(Lines[Lines.Count - 1]) - Lines.Count - 1, Length(Lines[Lines.Count - 1]), clBlue);

      Lines.Add('Line in green ');
      SetRangeColor(Length(Lines.Text) - Length(Lines[Lines.Count - 1]) - Lines.Count - 1, Length(Lines[Lines.Count - 1]), clGreen);
 ///////////////////////


      AddColorStr('Black, ');
      AddColorStr('Green, ', clGReen, false);
      AddColorStr('Blue, ', clBlue, false);
      AddColorStr('Red', clRed, false);

     //     SetRangeParams ( SelStart, SelLength,
     [tmm_Styles, tmm_Color], // changing Color and Styles only
     '',  // this is font name - it's not used, thus we can leave it empty
     0,  // this is font size - it's font size, we can leave it empty
     col, // making all the text in the selected region 'col' colored
     [fsBold],  // adding Bold [fsbold,and fsItalic Styles]
     []
  );
      }
