/*** BEGIN file-header ***/
#ifndef VALA_PANEL_ENUM_TYPES_H
#define VALA_PANEL_ENUM_TYPES_H

#include <glib-object.h>

G_BEGIN_DECLS

/*** END file-header ***/

/*** BEGIN file-production ***/
/* Enumerations from "@filename@" */
#include "@basename@"

/*** END file-production ***/

/*** BEGIN enumeration-production ***/
#define SN_TYPE_@ENUMSHORT@	(@enum_name@_get_type())
GType @enum_name@_get_type (void) G_GNUC_CONST;
const char * @enum_name@_get_nick (@EnumName@ value) G_GNUC_CONST;
@EnumName@ @enum_name@_get_value_from_nick (const char * nick) G_GNUC_CONST;

/*** END enumeration-production ***/

/*** BEGIN file-tail ***/
G_END_DECLS

#endif /* VALA_PANEL_ENUM_TYPES_H */
/*** END file-tail ***/

