//
//  iPrestaNSError.m
//  iPresta
//
//  Created by Nacho on 08/05/13.
//  Copyright (c) 2013 Nacho. All rights reserved.
//

#import "iPrestaNSError.h"


@implementation NSError (iPrestaNSError)

- (id)initWithCode:(int)code userInfo:(NSDictionary *)userInfo
{
    self = [[NSError alloc] initWithDomain:@"error" code:code userInfo:userInfo];
    return self;
}

- (void)manageError
{
    NSString *message;
    
    switch ([self code]) {
        case SERVER_ERROR: // Error interno
            message = IPString(@"Error interno");
            break;
        case CONNECTION_ERROR: // Error de conexión
            message = IPString(@"Problemas conexion");
            break;
        case URLCONNECTION_ERROR: // Error de conexión
            message = IPString(@"Problemas conexion");
            break;
        case REQUESTTIMEOUT_ERROR: // Error de tiempo de conexion
            message = IPString(@"Problemas conexion");
            break;
        case LOGIN_ERROR: // Error de Login
            message = IPString(@"Email password error");
            break;
        case SIGNIN_ERROR: // Error de registro
            message = IPString(@"Usuario existente");
            break;
        case REQUESTPASSWORDRESET_ERROR: // Error de recuperación de email
            message = IPString(@"Usuario no existente");
            break;
        case NOTCURRENTUSER_ERROR: // Error al modificar un usuario que no es el logueado
            message = IPString(@"Usuario no logueado");
            break;
        case EMPTYOBJECTDATA_ERROR: // Error al no encontrar ningun objeto
            message = IPString(@"Objeto no encontrado");
            break;
        case OBJECTNOTFOUND_ERROR: // Error al no encontrar ningun objeto
            message = IPString(@"Objeto no encontrado");
            break;
        case REPEATOBJECT_ERROR: // no se ha devuelto ningun objeto de la busqueda
            message = IPString(@"Objecto existente");
            break;
        case NOTAUTHENTICATEDUSER_ERROR:
            message = IPString(@"Email no autenticado");
            break;
        case FBLOGINUSEREXISTS_ERROR:
            message = [NSString stringWithFormat:IPString(@"Cuenta asociada facebook"), self.userInfo[@"email"]];
            break;
        case FBLOGIN_ERROR:
            message = IPString(@"Cuenta FB no existente");
            break;
        default:
            break;
    }
    
    UIWindow *window = [[[UIApplication sharedApplication] delegate] window];
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:APP_NAME message:message delegate:window cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [alert show];
}
@end
