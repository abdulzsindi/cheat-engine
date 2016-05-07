unit formAddressChangeUnit;

{$MODE Delphi}

interface

uses
  windows, LCLIntf, LResources, Messages, SysUtils, Variants, Classes, Graphics,
  Controls, Forms, Dialogs, StdCtrls, ExtCtrls, ComCtrls, Buttons, Arrow, Spin,
  CEFuncProc, NewKernelHandler, symbolhandler, memoryrecordunit, types, byteinterpreter,
  math, CustomTypeHandler, commonTypeDefs;

const WM_disablePointer=WM_USER+1;

type
  TformAddressChange=class;
  TPointerInfo=class;

  TOffsetInfo=class
  private
    fowner: TPointerInfo;
    fBaseAddress: ptruint;
    fOffset: Integer; //signed integer
    fInvalidOffset: boolean;

    lblPointerAddressToValue: TLabel; //Address -> Value
    edtOffset: Tedit;
    sbDecrease, sbIncrease: TSpeedButton;
    istop: boolean;

    repeatstart: dword;
    repeattimer: TTimer;
    repeatdirection: integer;
    stepsize: integer;
    procedure setOffset(o: integer);
    procedure offsetchange(sender: TObject);

    procedure RepeatClick(sender: TObject);
    procedure DecreaseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
    procedure IncreaseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
    procedure IncreaseDecreaseUp(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);

    procedure DecreaseClick(sender: TObject);
    procedure IncreaseClick(sender: TObject);
    procedure setBaseAddress(address: ptruint);

  public
    constructor create(parent: TPointerinfo);
    destructor destroy; override;
    function getAddressThisPointsTo(var address: ptruint): boolean;
    procedure setTop(var newtop: integer);
    procedure UpdateLabels;
    property owner: TPointerinfo read fowner;
    property offset: integer read foffset write setOffset;
    property invalidOffset: boolean read fInvalidOffset;
    property baseAddress: ptruint write setBaseAddress;
  end;


  TPointerInfo=class(TCustomPanel)
  private
    fowner: TformAddressChange;
    fBaseAddress: ptruint;
    fInvalidBaseAddress: boolean;
    fError: boolean;  //indicator for the child offsets, accessed by Error
    baseAddress: TEdit;  //the bottom line
    baseValue: Tlabel;
    offsets: Tlist; //the lines above it

    btnAddOffset: TButton;
    btnRemoveOffset: TButton;
    procedure selfdestruct;
    procedure basechange(sender: Tobject);
    procedure AddOffsetClick(sender: TObject);
    procedure RemoveOffsetClick(sender: TObject);
    function getValueLeft: integer;
    function getOffset(index: integer): TOffsetInfo;
    function getoffsetcount: integer;

    function getAddressThisPointsTo(var address: ptruint): boolean;

  public
    property owner: TformAddressChange read fowner;
    property valueLeft: integer read getValueLeft; //gets the basevalue.left
    property error: boolean read ferror;
    property invalidBaseAddress: boolean read fInvalidBaseAddress;
    property offsetcount: integer read getoffsetcount;
    property offset[Index: Integer]: TOffsetInfo read getOffset;

    procedure processAddress; //reads the base address and all the offsets and shows what it all does
    procedure setupPositionsAndSizes;


    constructor create(owner: TformAddressChange);
    destructor destroy; override;

  end;

  { TformAddressChange }

  TformAddressChange = class(TForm)
    editDescription: TEdit;
    Label12: TLabel;
    Label3: TLabel;
    lblValue: TLabel;
    pnlBitinfo: TPanel;
    cbunicode: TCheckBox;
    cbvarType: TComboBox;
    edtSize: TEdit;
    editAddress: TEdit;
    btnOk: TButton;
    btnCancel: TButton;
    cbPointer: TCheckBox;
    Label1: TLabel;
    Label10: TLabel;
    Label11: TLabel;
    Label2: TLabel;
    Label4: TLabel;
    Label5: TLabel;
    Label6: TLabel;
    Label7: TLabel;
    Label8: TLabel;
    Label9: TLabel;
    lengthlabel: TLabel;
    pnlExtra: TPanel;
    RadioButton1: TRadioButton;
    RadioButton2: TRadioButton;
    RadioButton3: TRadioButton;
    RadioButton4: TRadioButton;
    RadioButton5: TRadioButton;
    RadioButton6: TRadioButton;
    RadioButton7: TRadioButton;
    RadioButton8: TRadioButton;
    Timer1: TTimer;
    Timer2: TTimer;
    procedure btnCancelClick(Sender: TObject);
    procedure cbvarTypeChange(Sender: TObject);
    procedure editAddressChange(Sender: TObject);
    procedure FormActivate(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure cbPointerClick(Sender: TObject);
    procedure btnRemoveOffsetOldClick(Sender: TObject);
    procedure btnAddOffsetOldClick(Sender: TObject);
    procedure btnOkClick(Sender: TObject);
    procedure editAddressKeyPress(Sender: TObject; var Key: Char);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure FormWindowStateChange(Sender: TObject);
    procedure pcExtraChange(Sender: TObject);
    procedure tsStartbitContextPopup(Sender: TObject; MousePos: TPoint;
      var Handled: Boolean);
    procedure Timer1Timer(Sender: TObject);
    procedure Timer2Timer(Sender: TObject);
  private
    { Private declarations }
    pointerinfo: TPointerInfo;
    fMemoryRecord: TMemoryRecord;
    delayedpointerresize: boolean;
    procedure offsetKeyPress(sender: TObject; var key:char);
    procedure processaddress;
    procedure setMemoryRecord(rec: TMemoryRecord);
    procedure DelayedResize;
    procedure AdjustHeightAndButtons;
    procedure DisablePointerExternal(var m: TMessage); message WM_disablePointer;
    procedure setVarType(vt: TVariableType);
    function getVartype: TVariableType;
    procedure sLength(l: integer);
    function gLength: integer;
    procedure setStartbit(b: integer);
    function getStartbit: integer;
    procedure setUnicode(state: boolean);
    function getUnicode: boolean;
    procedure setDescription(s: string);
    function getDescription: string;
    procedure setAddress(var address: string; var offsets: Toffsetlist);
    function getAddress(var address: string; var offsets: ToffsetList): boolean;
  public
    { Public declarations }
    index: integer;
    index2: integer;
    property memoryrecord: TMemoryRecord read fMemoryRecord write setMemoryRecord;
    property vartype: TVariableType read getVartype write setVartype;
    property length: integer read gLength write sLength;
    property startbit: integer read getStartbit write setStartbit;
    property unicode: boolean read getUnicode write setUnicode;
    property description: string read getDescription write setDescription;
  end;

var
  formAddressChange: TformAddressChange;

implementation

uses MainUnit, formsettingsunit, ProcessHandlerUnit, Parsers;

resourcestring
  rsThisPointerPointsToAddress = 'This pointer points to address';
  rsTheOffsetYouChoseBringsItTo = 'The offset you chose brings it to';
  rsResultOfNextPointer = 'Result of next pointer';
  rsAddressOfPointer = 'Address of pointer';
  rsOffsetHex = 'Offset (Hex)';
  rsFillInTheNrOfBytesAfterTheLocationThePointerPoints = 'Fill in the nr. of bytes after the location the pointer points to';
  rsIsNotAValidOffset = '%s is not a valid offset';
  rsNotAllOffsetsHaveBeenFilledIn = 'Not all offsets have been filled in';
  rsACAddOffset = 'Add Offset';
  rsACRemoveOffset = 'Remove Offset';


{ TOffsetInfo }

procedure TOffsetInfo.RepeatClick(sender: TObject);
begin
  if repeatdirection=0 then
    DecreaseClick(nil)
  else
    IncreaseClick(nil);

  repeattimer.Interval:=max(10,500-((GetTickCount-repeatstart) div 10));
end;

procedure TOffsetInfo.DecreaseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  if repeattimer<>nil then
    freeandnil(repeattimer);

  if ssCtrl in shift then
    stepsize:=1
  else if ssShift in shift then
    stepsize:=ifthen(processhandler.pointersize=8, 4, 8)
  else
    stepsize:=ifthen(istop, 4, processhandler.pointersize);

  repeatstart:=GetTickCount;
  repeatdirection:=0; //tell the timer to decrease

  repeattimer:=TTimer.Create(self.owner.owner);
  repeattimer.Interval:=500;
  repeattimer.OnTimer:=RepeatClick;

  DecreaseClick(sender);
end;

procedure TOffsetInfo.IncreaseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  if repeattimer<>nil then
    freeandnil(repeattimer);

  if ssCtrl in shift then
    stepsize:=1
  else if ssShift in shift then
    stepsize:=ifthen(processhandler.pointersize=8, 4, 8)
  else
    stepsize:=ifthen(istop, 4, processhandler.pointersize);

  repeatstart:=GetTickCount;
  repeatdirection:=1; //tell the timer to increase
  repeattimer:=TTimer.Create(self.owner.owner);
  repeattimer.Interval:=500;
  repeattimer.OnTimer:=RepeatClick;

  IncreaseClick(sender);
end;

procedure TOffsetInfo.IncreaseDecreaseUp(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  //destroy the repeat timer
  if repeattimer<>nil then
    freeandnil(repeattimer);
end;


procedure TOffsetInfo.DecreaseClick(sender: TObject);
begin
  offset:=offset-stepsize;
end;

procedure TOffsetInfo.IncreaseClick(sender: TObject);
begin
  offset:=offset+stepsize;
end;


function TOffsetInfo.getAddressThisPointsTo(var address: ptruint): boolean;
var x: ptruint;
begin
  //use the baseaddress and offset to get to the address

  result:=false;
  if not invalidOffset then
  begin
    address:=0;
    result:=ReadProcessMemory(processhandle, pointer(fBaseAddress+fOffset), @address, processhandler.pointersize, x);
  end;
end;

procedure TOffsetInfo.UpdateLabels;
var Sbase: string;
  Soffset: string;
  Spointsto: string;
  sign: string;
  e: boolean;
  success: boolean;
  a: ptruint;
  newwidth: integer;
begin
  e:=false;
  if owner.error then
  begin
    Sbase:='????????';
    e:=true;
  end
  else
    Sbase:=inttohex(fBaseAddress,8);

  if invalidOffset then
  begin
    sign:='+';
    Soffset:='?';
    e:=true;
  end
  else
  begin
    if fOffset>=0 then
    begin
      sign:='+';
      Soffset:=inttohex(fOffset,1);
    end
    else
    begin
      sign:='-';
      Soffset:=inttohex(-fOffset,1);
    end;
  end;

  if not e then
  begin
    success:=getAddressThisPointsTo(a);
    if success then
      SPointsTo:=inttohex(a,8)
    else
      SPointsTo:='????????';
  end
  else
  begin
    SPointsTo:='????????';
  end;

  if istop then
  begin
    if e then
      lblPointerAddressToValue.Caption:=sbase+sign+soffset+' = ????????'
    else
    begin
      if processhandler.is64bit then
        lblPointerAddressToValue.Caption:=sbase+sign+soffset+' = '+inttohex(qword(fBaseAddress+offset),8)
      else
        lblPointerAddressToValue.Caption:=sbase+sign+soffset+' = '+inttohex(dword(fBaseAddress+offset),8)

    end;
  end
  else
    lblPointerAddressToValue.Caption:='['+sbase+sign+soffset+'] -> '+SPointsTo;

  //update positions
  newwidth:=lblPointerAddressToValue.left+lblPointerAddressToValue.Width;
  if newwidth>owner.ClientWidth then
  begin
    owner.ClientWidth:=newwidth+16;
    owner.owner.ClientWidth:=owner.left+owner.ClientWidth;
  end;
end;


procedure TOffsetInfo.setOffset(o: integer);
var s: string;
begin
  finvalidOffset:=false;


  s:=lowercase(IntToHexSigned(o,1));
  if lowercase(edtOffset.text)<>s then //needs to be updated
  begin
    edtOffset.OnChange:=nil; //disable the onchange
    edtOffset.text:=s;
    edtOffset.OnChange:=offsetchange; //set it back
  end;

  fOffset:=o;
  owner.processAddress;
end;

procedure TOffsetInfo.setBaseAddress(address: ptruint);
begin
  fBaseAddress:=address;
  UpdateLabels;
end;

procedure TOffsetInfo.offsetchange(sender: TObject);
begin
  try
    offset:=StrToQWordEx(ConvertHexStrToRealStr(utf8toansi(tedit(sender).Text)));
    edtOffset.Font.Color:=clDefault;
    finvalidOffset:=false;
  except
    edtOffset.Font.Color:=clRed;
    finvalidOffset:=true;
    UpdateLabels;
  end;
end;

procedure TOffsetInfo.setTop(var newtop: integer);
{
Sets the offset's position and returns the position for the new offsetline
}
begin
  if edtOffset.parent=nil then
  begin
    //only assign a parent when the positions ar finally set
    edtOffset.parent:=owner;
    lblPointerAddressToValue.parent:=owner;
    sbDecrease.parent:=owner;
    sbIncrease.parent:=owner;
  end;


  //only show the pointeraddresstovalue line if not the first line
  edtOffset.taborder:=owner.offsets.IndexOf(self);
  istop:=edtOffset.taborder=0;

  sbDecrease.top:=newtop;
  sbIncrease.top:=newtop;
  edtOffset.top:=newtop;

  sbDecrease.left:=0;
  edtOffset.left:=sbDecrease.left+sbDecrease.Width+1;
  sbIncrease.left:=edtOffset.Left+edtOffset.Width+1;

  lblPointerAddressToValue.top:=edtOffset.top + (edtOffset.Height div 2) - (lblPointerAddressToValue.Height div 2);
  lblPointerAddressToValue.left:=sbIncrease.Left+sbIncrease.Width+3;
  lblPointerAddressToValue.visible:=true;


  newtop:=sbDecrease.top+sbDecrease.height+3;
end;

destructor TOffsetInfo.destroy;
begin
  if lblPointerAddressToValue<>nil then
    freeandnil(lblPointerAddressToValue);

  if edtOffset<>nil then
    freeandnil(edtOffset);

  if sbDecrease<>nil then
    freeandnil(sbDecrease);

  if sbIncrease<>nil then
    freeandnil(sbIncrease);

  fowner.offsets.Remove(self);
  inherited destroy;
end;

constructor TOffsetInfo.create(parent: TPointerinfo);
var insertinsteadofadd: boolean;
begin
  stepsize:=4;
  fowner:=parent;

  //check if ctrl is pressed, if so, insert instead of append (or the other way depending on settings)

  insertinsteadofadd:=not formsettings.cbOldPointerAddMethod.checked; //append pointerline instead of insert
  if (((GetKeyState(VK_CONTROL) shr 15) and 1)=1) then
    insertinsteadofadd:=not insertinsteadofadd;

  if insertinsteadofadd then
    fowner.offsets.Insert(0, self)
  else
    fowner.offsets.Add(self);

  //create a pointeraddress label (visible if not first)
  lblPointerAddressToValue:=TLabel.Create(parent);
  lblPointerAddressToValue.Caption:=' ';
  lblPointerAddressToValue.parent:=parent;

  //an offset editbox
  fOffset:=0;
  edtOffset:=Tedit.create(parent);
  edtOffset.Text:='0';

  edtOffset.Alignment:=taCenter;
  edtOffset.OnChange:=OffsetChange;


  //two buttons, one for + and one for -
  sbDecrease:=TSpeedButton.create(parent);
  sbDecrease.height:=edtOffset.height;
  sbDecrease.width:=sbDecrease.height;
  sbDecrease.caption:='<';
 // sbDecrease.OnClick:=DecreaseClick;
  sbDecrease.OnMouseDown:=DecreaseDown;
  sbDecrease.OnMouseUp:=IncreaseDecreaseUp;


  sbIncrease:=TSpeedButton.create(parent);
  sbIncrease.height:=sbDecrease.height;
  sbIncrease.width:=sbDecrease.width;
  sbIncrease.caption:='>';
 // sbIncrease.OnClick:=IncreaseClick;
  sbIncrease.OnMouseDown:=IncreaseDown;
  sbIncrease.OnMouseUp:=IncreaseDecreaseUp;

  edtOffset.width:=owner.baseAddress.Width-2*sbIncrease.Height-2;


end;

{ TPointerInfo }

procedure TPointerInfo.AddOffsetClick(sender: TObject);
begin
  TOffsetInfo.Create(self);
  setupPositionsAndSizes;
end;

procedure TPointerInfo.RemoveOffsetClick(sender: TObject);
var insertinsteadofadd: boolean;
  o: TOffsetInfo;
begin
  insertinsteadofadd:=not formsettings.cbOldPointerAddMethod.checked; //append pointerline instead of insert
  if (((GetKeyState(VK_CONTROL) shr 15) and 1)=1) then
    insertinsteadofadd:=not insertinsteadofadd;

  if insertinsteadofadd then //remove the first offset in the list
    o:=TOffsetinfo(offsets[0])
  else
    o:=TOffsetInfo(offsets[offsets.Count-1]);

  o.free;

  if offsets.Count>0 then
    setupPositionsAndSizes
  else
    selfdestruct;
end;

procedure TPointerInfo.selfdestruct;
begin
  postmessage(owner.handle, WM_disablePointer, 0,0);
end;

function TPointerInfo.getValueLeft: integer;
begin
  result:=baseValue.left;
end;

function TPointerInfo.getOffset(index: integer): TOffsetInfo;
begin
  result:=TOffsetInfo(offsets[index]);
end;

function TPointerInfo.getoffsetcount: integer;
begin
  result:=offsets.Count;
end;

function TPointerInfo.getAddressThisPointsTo(var address: ptruint): boolean;
var x: ptruint;
begin
  result:=false;
  if not InvalidBaseAddress then
  begin
    address:=0; //clear all bits
    result:=ReadProcessMemory(processhandle, pointer(fBaseAddress), @address, processhandler.pointersize, x);
  end;
end;


procedure TPointerInfo.basechange(sender: Tobject);
var e: boolean;
begin
  fBaseAddress:=symhandler.getAddressFromName(utf8toansi(baseAddress.text), false, e);
  fInvalidBaseAddress:=e;

  if fInvalidBaseAddress then
    baseAddress.Font.Color:=clRed
  else
    baseAddress.Font.Color:=clDefault;

  processAddress;
end;

procedure TPointerInfo.processAddress;
var base: PtrUInt;
  i: integer;
  e: boolean;
begin
  ferror:=not getAddressThisPointsTo(base);

  if error then
    baseValue.caption:='->????????'
  else
    baseValue.caption:='->'+inttohex(base,8);

  for i:=offsetcount-1 downto 1 do
  begin
    offset[i].baseaddress:=base;
    if not offset[i].getAddressThisPointsTo(base) then
      ferror:=true; //signal an error to all subsequent offsets
  end;

  //add the last offset
  offset[0].baseaddress:=base;
  base:=base+offset[0].offset;

  if error then
    owner.editAddress.text:='????????'
  else
    owner.editAddress.text:=inttohex(base,8);
end;

procedure TPointerInfo.setupPositionsAndSizes;
var
  currentTop: integer;
  i: integer;
  newwidth: integer;
begin
  //place offsets and set size


  currentTop:=0;
  for i:=0 to offsets.count-1 do
  begin
    TOffsetInfo(offsets[i]).setTop(currentTop);
    TOffsetInfo(offsets[i]).edtOffset.TabOrder:=i;
  end;



  baseAddress.top:=currentTop;
  baseValue.top:=baseAddress.Top+(baseAddress.Height div 2)-(baseValue.height div 2);

  btnAddOffset.top:=baseAddress.top+baseAddress.Height+3;
  btnRemoveOffset.top:=btnAddOffset.top;

  ClientHeight:=btnAddOffset.Top+btnAddOffset.Height+3;
  //Width will be set using the UpdateLabels method of individial offsets when the current offset is too small


  //update buttons of the form
  with owner do
  begin
    btnOk.top:=self.top+self.height+3;
    btnCancel.top:=btnOk.top;
    ClientHeight:=btnOk.top+btnOk.Height+3;
    ClientWidth:=self.ClientWidth+self.Left;
  end;

  processAddress;
end;

destructor TPointerInfo.destroy;
begin
  if offsets<>nil then
    while offsets.count>0 do //destruction of a offset removes it automagically from the list
      TOffsetInfo(offsets[0]).Free;

  owner.btnOk.top:=owner.cbPointer.Top+owner.cbPointer.Height+3;
  owner.btnCancel.top:=owner.btnOk.top;
  owner.ClientHeight:=owner.btnOk.top+owner.btnOk.Height+3;
  owner.editAddress.enabled:=true;

  if baseAddress<>nil then
    freeandnil(baseAddress);

  if baseValue<>nil then
    freeandnil(baseValue);

  if btnAddOffset<>nil then
    freeandnil(btnAddOffset);

  if btnRemoveOffset<>nil then
    freeandnil(btnRemoveOffset);


  inherited Destroy;
end;

constructor TPointerInfo.create(owner: TformAddressChange);
begin
  //create the objects
  inherited create(owner);


  fowner:=owner;
  offsets:=tlist.create;
  parent:=owner;

  BevelOuter:=bvNone;
  left:=owner.cbPointer.Left;
  top:=owner.cbPointer.Top+owner.cbPointer.Height+3;

  taborder:=owner.cbPointer.TabOrder+1;

  baseAddress:=tedit.create(self);
  baseAddress.parent:=self;
  baseAddress.left:=0;
  if ProcessHandler.is64Bit then
    baseAddress.Width:=128
  else
    baseAddress.Width:=88;

  baseAddress.OnChange:=basechange;


  baseValue:=tlabel.create(self);
  baseValue.caption:=' ';
  baseValue.parent:=self;
  baseValue.left:=baseAddress.left+baseAddress.Width+3;
  baseValue.top:=baseAddress.Top+(baseAddress.Height div 2)-(baseValue.height div 2);

  btnAddOffset:=Tbutton.Create(self);
  btnAddOffset.caption:=rsACAddOffset;
  btnAddOffset.Left:=owner.btnOk.Left-left;
  btnAddOffset.Width:=owner.btnOk.Width;
  btnAddOffset.Height:=owner.btnOk.Height;
  btnAddOffset.OnClick:=AddOffsetClick;
  btnAddOffset.parent:=self;

  btnRemoveOffset:=TButton.create(self);
  btnRemoveOffset.caption:=rsACRemoveOffset;
  btnRemoveOffset.Left:=owner.btnCancel.left-left;
  btnRemoveOffset.Width:=btnAddOffset.Width;
  btnRemoveOffset.Height:=btnAddOffset.Height;
  btnRemoveOffset.OnClick:=RemoveOffsetClick;
  btnRemoveOffset.parent:=self;


  TOffsetInfo.Create(self);

  owner.editAddress.enabled:=false;
  setupPositionsAndSizes;
end;

{ Tformaddresschange }

procedure Tformaddresschange.setAddress(var address: string; var offsets: Toffsetlist);
var i: integer;
begin
  if system.length(offsets)=0 then
  begin
    //no pointer
    cbPointer.Checked:=false;
    editAddress.Text:=ansitoutf8(address);
  end
  else
  begin
    //pointer
    cbPointer.Checked:=true;
    pointerinfo.baseAddress.Text:=ansitoutf8(address);

    //create offsets
    for i:=pointerinfo.offsetcount to system.length(offsets)-1 do
      TOffsetInfo.create(pointerinfo);

    pointerinfo.setupPositionsAndSizes;

    for i:=0 to system.length(offsets)-1 do
      pointerinfo.offset[i].offset:=offsets[i];

    pointerinfo.processAddress;
  end;

end;

function Tformaddresschange.getAddress(var address: string; var offsets: ToffsetList): boolean;
var
  i: integer;
begin
  result:=false;
  if pointerinfo=nil then
  begin
    setlength(offsets,0);
    address:=utf8toansi(editAddress.Text);
    result:=true;
  end
  else
  begin
    if not pointerinfo.invalidBaseAddress then
    begin
      address:=utf8toansi(pointerinfo.baseAddress.text);
      setlength(offsets, pointerinfo.offsetcount);

      for i:=pointerinfo.offsetcount-1 downto 0 do //fill the array inverse
        offsets[i]:=pointerinfo.offset[pointerinfo.offsetcount-1-i].offset;

      result:=true;
    end;
  end;
end;

procedure Tformaddresschange.setDescription(s: string);
begin
  editDescription.Text:=s;
end;

function Tformaddresschange.getDescription: string;
begin
  result:=editDescription.Text;
end;

procedure Tformaddresschange.setUnicode(state: boolean);
begin
  cbunicode.checked:=state;
end;

function Tformaddresschange.getUnicode: boolean;
begin
  result:=cbunicode.checked;
end;

procedure Tformaddresschange.setStartbit(b: integer);
begin
  case b of
    0: RadioButton1.checked:=true;
    1: RadioButton2.checked:=true;
    2: RadioButton3.checked:=true;
    3: RadioButton4.checked:=true;
    4: RadioButton5.checked:=true;
    5: RadioButton6.checked:=true;
    6: RadioButton7.checked:=true;
    7: RadioButton8.checked:=true;
  end;
end;

function Tformaddresschange.getStartbit: integer;
begin
  result:=0;
  if RadioButton1.checked then
    result:=0
  else
  if RadioButton2.checked then
    result:=1
  else
  if RadioButton3.checked then
    result:=2
  else
  if RadioButton4.checked then
    result:=3
  else
  if RadioButton5.checked then
    result:=4
  else
  if RadioButton6.checked then
    result:=5
  else
  if RadioButton7.checked then
    result:=6
  else
  if RadioButton8.checked then
    result:=7;

end;

procedure Tformaddresschange.sLength(l: integer);
begin
  edtSize.text:=inttostr(l);
end;

function Tformaddresschange.gLength: integer;
begin
  result:=StrToIntDef(edtSize.Text,0)
end;

procedure Tformaddresschange.setVarType(vt: TVariableType);
begin
  cbvarType.onchange:=nil;
  case vt of
    vtBinary: cbvarType.ItemIndex:=0;
    vtByte: cbvarType.ItemIndex:=1;
    vtWord: cbvarType.ItemIndex:=2;
    vtDword: cbvarType.ItemIndex:=3;
    vtQword: cbvarType.ItemIndex:=4;
    vtSingle: cbvarType.ItemIndex:=5;
    vtDouble: cbvarType.ItemIndex:=6;
    vtString: cbvarType.ItemIndex:=7;
    vtByteArray: cbvarType.ItemIndex:=8;
  end;
  cbvarType.onchange:=cbvarTypeChange;
  cbvarTypeChange(cbvarType);
end;

function Tformaddresschange.getVartype: TVariableType;
var i: integer;
begin
  {
  Binary
  Byte
  2 Bytes
  4 Bytes
  8 Bytes
  Float
  Double
  Text
  Array of Bytes
  <custom types>
  }
  i:=cbvarType.ItemIndex;
  case i of
    0: result:=vtBinary;
    1: result:=vtByte;
    2: result:=vtWord;
    3: result:=vtDword;
    4: result:=vtQword;
    5: result:=vtSingle;
    6: result:=vtDouble;
    7: result:=vtString;
    8: result:=vtByteArray;
    else
      result:=vtCustom;
  end;
end;


procedure Tformaddresschange.processaddress;
var a: PtrUInt;
  e: boolean;
begin
  //read the address and display the value it points to

  a:=symhandler.getAddressFromName(utf8toansi(editAddress.Text),false,e);
  if not e then
  begin
    //get the vartype and parse it
    lblValue.caption:='='+readAndParseAddress(a, vartype, TcustomType(cbvarType.items.objects[cbvarType.ItemIndex]),false, false, StrToIntDef(edtSize.text,1));
  end
  else
    lblValue.caption:='=???';



end;


procedure Tformaddresschange.offsetKeyPress(sender: TObject; var key:char);
begin
{  if key<>'-' then hexadecimal(key);
  if cbpointer.Checked then timer1.Interval:=1;   }

end;


procedure TformAddressChange.FormClose(Sender: TObject;
  var Action: TCloseAction);
begin

end;

procedure TformAddressChange.FormActivate(Sender: TObject);
begin

end;

procedure TformAddressChange.cbvarTypeChange(Sender: TObject);
begin
  pnlExtra.visible:=cbvarType.itemindex in [0,7,8];
  pnlBitinfo.visible:=cbvarType.itemindex = 0;
  cbunicode.visible:=cbvarType.itemindex = 7;

  AdjustHeightAndButtons;

  processaddress;
end;

procedure TformAddressChange.btnCancelClick(Sender: TObject);
begin

end;

procedure TformAddressChange.editAddressChange(Sender: TObject);
begin
  processaddress;
end;

procedure TformAddressChange.DelayedResize;
begin
  AdjustHeightAndButtons;
end;

procedure TformAddressChange.cbPointerClick(Sender: TObject);
var i: integer;
    startoffset,inputoffset,rowheight: integer;

    a,b,c,d: integer;
begin
  if cbpointer.checked then
  begin
    if pointerinfo=nil then
      pointerinfo:=TPointerInfo.create(self); //creation will do the gui update
  end
  else
  begin
    if pointerinfo<>nil then
      freeandnil(pointerinfo);
  end;

end;

procedure TformAddressChange.DisablePointerExternal(var m: TMessage);
begin
  cbPointer.Checked:=false;
end;

procedure TformAddressChange.AdjustHeightAndButtons;
var i: integer;
begin
  if pnlExtra.visible then
  begin

    //check if pnlbits is visible
    if pnlBitinfo.visible then
      pnlExtra.height:=pnlBitinfo.Top+pnlBitinfo.Height+3
    else
      pnlExtra.height:=edtSize.top+edtSize.Height+3;


    cbPointer.top:=pnlExtra.top+pnlExtra.Height+3;
  end
  else
    cbPointer.top:=cbvarType.top+cbvarType.Height+3;


  if pointerinfo=nil then
    btnok.top:=cbPointer.Top+cbPointer.Height+3
  else
  begin
    pointerinfo.top:=cbPointer.Top+cbPointer.Height+3;
    btnok.top:=pointerinfo.Top+pointerinfo.Height+3;

    pointerinfo.setupPositionsAndSizes;
  end;


  btnCancel.top:=btnok.top;
  clientheight:=btncancel.top+btnCancel.height+6;
end;

procedure TformAddressChange.btnRemoveOffsetOldClick(Sender: TObject);
begin

end;

procedure TformAddressChange.btnAddOffsetOldClick(Sender: TObject);
begin

end;

procedure TformAddressChange.setMemoryRecord(rec: TMemoryRecord);
var i: integer;
    tmp:string;
begin
  fMemoryRecord:=rec;

  description:=rec.Description;
  vartype:=rec.VarType;

  setAddress(rec.interpretableaddress, rec.pointeroffsets);

  case fMemoryRecord.vartype of
    vtBinary:
    begin
      startbit:=rec.Extra.bitData.Bit;
      length:=rec.Extra.bitdata.bitlength;
    end;

    vtString:
    begin
      unicode:=rec.Extra.stringData.unicode;
      length:=rec.Extra.stringData.length;
    end;

    vtByteArray:
    begin
      length:=rec.Extra.byteData.bytelength;
    end;

    vtCustom:
      cbvarType.ItemIndex:=cbvarType.Items.IndexOf(fMemoryRecord.CustomTypeName);

  end;


  processaddress;
  AdjustHeightAndButtons;

end;

procedure TformAddressChange.btnOkClick(Sender: TObject);
var bit: integer;
    address: string;
    err:integer;

    paddress: dword;
    offsets: array of integer;

    i: integer;
begin
  memoryrecord.Vartype:=vartype;


  case vartype of
    vtBinary:
    begin
      memoryrecord.Extra.bitData.Bit:=startbit;
      memoryrecord.Extra.bitData.bitlength:=length;
    end;

    vtString:
    begin
      memoryrecord.Extra.stringData.length:=length;
      memoryrecord.Extra.stringData.unicode:=unicode;
    end;

    vtByteArray:
      memoryrecord.Extra.byteData.bytelength:=length;

    vtCustom:
      memoryrecord.CustomTypeName:=cbvarType.Caption;

  end;

  memoryrecord.Description:=description;

  getAddress(address, offsets);
  memoryrecord.interpretableaddress:=address;
  setlength(memoryrecord.pointeroffsets, system.length(offsets));
  for i:=0 to system.length(offsets)-1 do
    memoryrecord.pointeroffsets[i]:=offsets[system.length(offsets)-1-i];


  modalresult:=mrok;
end;

procedure TformAddressChange.editAddressKeyPress(Sender: TObject;
  var Key: Char);
begin

end;

procedure TformAddressChange.FormCreate(Sender: TObject);
var i: integer;
begin
  //fill the varlist with custom types
  for i:=0 to customTypes.Count-1 do
    cbvarType.Items.AddObject(TCustomType(customtypes[i]).name, customtypes[i]);


  cbvarType.DropDownCount:=cbvarType.Items.Count;
end;

procedure TformAddressChange.FormDestroy(Sender: TObject);
begin
  if pointerinfo<>nil then
    freeandnil(pointerinfo);
end;

procedure TformAddressChange.FormShow(Sender: TObject);
begin

end;

procedure TformAddressChange.FormWindowStateChange(Sender: TObject);
begin

end;

procedure TformAddressChange.pcExtraChange(Sender: TObject);
begin

end;

procedure TformAddressChange.tsStartbitContextPopup(Sender: TObject;
  MousePos: TPoint; var Handled: Boolean);
begin

end;

procedure TformAddressChange.Timer1Timer(Sender: TObject);
begin
  timer1.Interval:=1000;
  if visible and cbpointer.checked then
    if pointerinfo<>nil then
      pointerinfo.processaddress;

  processaddress;

end;

procedure TformAddressChange.Timer2Timer(Sender: TObject);
begin
  //lazarus bug bypass for not setting proper width when the window is not visible, and no event to signal when it's finally visible (onshow isn't one of them)
  DelayedResize;

  timer2.enabled:=false;
end;

initialization
  {$i formAddressChangeUnit.lrs}

end.