﻿script "com.livecode.pi.number.behavior"
local sFieldWidth, sMax, sMin

constant SLIDER_MAX_WIDTH = 130
constant SLIDER_MIN_WIDTH = 80
constant CONTROL_PADDING = 5

on editorInitialize
   lock screen
   lock messages
   local tStep
   put editorPropertyGet("max") into sMax
   put editorPropertyGet("min") into sMin
   put editorPropertyGet("step") into tStep
   
   if tStep is a number then
      set the lineinc of scrollbar "twiddle" of me to tStep
      set the visible of scrollbar "twiddle" of me to true
   else
      set the visible of scrollbar "twiddle" of me to false
   end if
   
   if sMax is a number and sMin is a number and sMax > sMin then
      put sMax into field 1 of me
      put the formattedwidth of field 1 of me into sFieldWidth
      set the visible of scrollbar "slider" of me to true
      set the endvalue of scrollbar "slider"of me to sMax
      set the startvalue of scrollbar "slider" of me to sMin
   else
      set the visible of scrollbar "slider" of me to false
   end if
   
   local tMinWidth
   put 25 into tMinWidth
   if the visible of scrollbar "slider"of me is true then add 25 to tMinWidth
   
   unlock messages
   unlock screen
   
   set the editorMinWidth of me to tMinWidth
   set the editorMaxWidth of me to 0
end editorInitialize

getProp editorMinWidth
   local tWidth
   add sFieldWidth to tWidth
   if the visible of scrollbar "slider" of me is true then
      add SLIDER_MIN_WIDTH to tWidth
      add CONTROL_PADDING to tWidth
   end if
   if the visible of scrollbar "twiddle" of me is true then
      add the width of scrollbar "twiddle" of me to tWidth
      add CONTROL_PADDING to tWidth
   end if
   return tWidth
end editorMinWidth

on editorUpdate
   lock screen
   local tValue, tEffective, tEnabled
   put the editorValue of me into tValue
   put the editorEnabled of me into tEnabled
   put the editorEffective of me into tEffective
   
   lock messages
   set the thumbposition of scrollbar "slider" of me to tValue + 0
   set the thumbposition of scrollbar "twiddle" of me to tValue + 0
   set the enabled of field 1 of me to tEnabled
   if tEffective is true then
      if the focusedobject is not the long ID of field 1 of me then
         put tValue + 0 into field 1 of me
      end if
      set the textcolor of field 1 of me to "150,150,150"
   else
      set the textcolor of field 1 of me to empty
      put tValue + 0 into field 1 of me
   end if
   unlock messages
   
   unlock screen
end editorUpdate

on editorResize
   lock screen
   lock messages
   
   local tLeft, tTop
   put the left of me into tLeft
   put the top of me into tTop
   if sFieldWidth > 0 then
      # The field has a fixed size
      set the rect of field 1 of me to tLeft,tTop,tLeft+sFieldWidth,tTop + the height of field 1 of me
      add sFieldWidth + CONTROL_PADDING to tLeft
   else if the visible of scrollbar "twiddle" is true then
      # The field is full width but there is a twiddle controller at the end
      set the rect of field 1 of me to tLeft,tTop,the right of me - the width of scrollbar "twiddle" - CONTROL_PADDING,tTop + the height of field 1 of me
      add the width of field 1 of me to tLeft
   end if
   
   if the visible of scrollbar "twiddle" of me is true then
      # The twiddle control is visible
      set the topleft of scrollbar "twiddle" of me to tLeft,tTop
      add the width of scrollbar "twiddle" of me + CONTROL_PADDING to tLeft
   end if
   
   if the visible of scrollbar 1 of me is true then
      # The slider is visible
      local tRemainingWidth
      put the right of me - tLeft + CONTROL_PADDING into tRemainingWidth
      if tRemainingWidth > SLIDER_MAX_WIDTH then
         put SLIDER_MAX_WIDTH into tRemainingWidth
      end if
      set the width of scrollbar "slider" of me to tRemainingWidth
      set the topleft of scrollbar "slider" of me to tLeft,tTop
   end if
   
   unlock messages
   unlock screen
end editorResize

on openField
   if the editorEffective of me is true then
      lock messages
      put empty into field 1 of me
      # Ensure that when the user types the text is the default color rather than the effective grey
      set the textcolor of field 1 of me to empty
      unlock messages
   end if
end openField

on exitField
   editorUpdate
end exitField

on returnInField
   valueChanged
end returnInField

on enterInField
   valueChanged
end enterInField

on closeField
   valueChanged
end closeField

on scrollbarDrag pValue
   if the visible of scrollbar "slider" of me is false then
      exit scrollbarDrag
   end if
   scrollbarValueChanged pValue
end scrollbarDrag

on scrollbarLineInc
   if the visible of scrollbar "twiddle" of me is false then
      exit scrollbarLineInc
   end if
   scrollbarValueChanged field 1 of me - 1
end scrollbarLineInc

on scrollbarLineDec
   if the visible of scrollbar "twiddle" of me is false then
      exit scrollbarLineDec
   end if
   scrollbarValueChanged field 1 of me + 1
end scrollbarLineDec

on scrollbarValueChanged pValue
   if pValue is field 1 of me then
      exit scrollbarValueChanged
   end if
   
   if sMin is a number and pValue < sMin then
      put sMin into field 1 of me
   else if sMax is a number and pValue > sMax then
      put sMax into field 1 of me
   else
      put pValue into field 1 of me
   end if
   valueChanged
end scrollbarValueChanged

on valueChanged
   if field 1 of me is a number  then
      lock messages
      set the thumbposition of scrollbar "slider" of me to field 1 of me
      unlock messages
   end if
   
   set the editorValue of me to field 1 of me
   updateProperty
end valueChanged
